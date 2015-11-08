# program that calculates the average degree of hashtags.
# we maintain the graph as adj matrix with one entry per
# vertex combination vs time and another structure called time graph that is
# time vs all vertex combinations. When a new entry arives 
# its time is updated in our adj matrix and the our time graph is refactored.
# At any given point total degree is twice the sum of all the vertices in our time graph
# and avg is this sum divided by total entry in adj matrix. Entries older than the 
# calculation window size is purged out of both of these structures. The thing to note here
# is time graph is just an inverse structure of our adj matrix.

require 'tweets_cleaned'
require 'time'
#require 'profile'

ROLLING_WINDOW_SIZE = 60 # no of seconds a tweet live in our graph system
BUCKET_SIZE = 1 # how often our graph is refreshed

class RollingHashtagGraph
  attr :time_graph # epoch time vs vertex combination
  attr :adj_matrix # vertex combination vs time
  attr :last_entry_time # timestamp of the last entry was added
  attr :last_avg # stores and returns the last avg if there is no change
  attr :is_change # tracks if there is a change to the graph system

  def initialize
    @time_graph = {}
    @adj_matrix = {}
    @last_entry_time = 0
    @last_avg = 0
    @is_change = false
  end

  # get the list of vertex combinations 
  def get_vertex_combinations(hashtags)
    combinatins = []
    combinations = hashtags.combination(2).to_a
  end

  # sum of all vetex combinations multiplied by 2
  def get_degree
    degree = 0

    @time_graph.each do |k, te|
      degree += te.count
    end

    return 2*degree
  end

  def get_all_vertices
    all_vertices = []

    @adj_matrix.each do |k, v|
      all_vertices.concat(k)
    end

    return all_vertices.uniq
  end

  # purges vertices not in rolling window sized time frame
  def purge
     @time_graph.each do |t, te|
       if t <= (@last_entry_time - ROLLING_WINDOW_SIZE)
         te.each { |e| @adj_matrix.delete(e) }
         @time_graph.delete(t)
       end
    end
  end

  def update_times(timestamp, combination)
    # update last entry time
    if @last_entry_time < timestamp
      @last_entry_time = timestamp
    end

    # update the entry in adj matrix
    @adj_matrix[combination] = timestamp

    # add new entry to time graph
    time_entry = @time_graph.fetch(timestamp,[])
    time_entry.push(combination)
    @time_graph[timestamp] = time_entry.uniq
  end

  # adds an entry to our graph system
  def add_entry(timestamp, combination)
    if timestamp == nil || timestamp == 0 || combination == nil || combination.count < 2
      @is_change = false
      return
    end

    puts "time #{timestamp} combination #{combination}"

    # set there is a modification
    @is_change = true

    # sort each combination
    combination.sort!

    # update the timestamp only if this is a new entry 
    # or old entry has a timestamp lesser than the new one
    old_time = adj_matrix.fetch(combination, 0)
    if old_time != 0
      if old_time < timestamp
        @time_graph[old_time].delete(combination)

        update_times(timestamp, combination)
      end
    else
      update_times(timestamp, combination)
    end
  end

  def add(time, text)
    if time == nil || time.empty? || text == nil || text.empty?
      return
    end

    hashtags = text.scan(/#\w+/).uniq
    timestamp = Time.parse(time).to_i

    combinations = get_vertex_combinations(hashtags)

    # add each combination to our graph system
    combinations.each do |c|
      add_entry(timestamp, c)
    end

    # purge old entries
    purge
  end

  # returns average degree
  def get_average_degree

    if !is_change
      return @last_avg
    end
    
    degree = get_degree

    vertices_count = get_all_vertices.count

    if vertices_count == 0
      return 0
    end

    @last_avg = (degree.to_f/vertices_count).round(2)
    return @last_avg
  end

  def get_time_graph
    return @time_graph
  end

  def get_graph
    return @adj_matrix
  end

  # combine the graph in arg to this one
  def combine(rolling_graph)
    if rolling_graph == nil
      return
    end
    
    # get the graph system
    time_graph = rolling_graph.get_time_graph
    adj_matrix = rolling_graph.adj_matrix

    # first find duplicate elements in both adj_matrices
    dup = adj_matrix.keys & @adj_matrix.keys

    # non dup the adj_matrix and time_graph
    dup.each do |d| 
      adj_matrix.delete(d)
      time = adj_matrix[d]
      time_graph[time].delete!(d)
    end

    # concat adj matrices and time graphs
    @adj_matrix.concat(adj_matrix)
    time_graph.each { |k, v| @time_graph[k].concat(v) }
  end

end

def usage 
  puts "usage: \n\t#{$0} <tweet_input_file>"
  exit
end

if $0 == __FILE__
  if ARGV.count != 2
    usage()
  end

  rolling_graph = RollingHashtagGraph.new
  output_file = File.open(ARGV[1], 'w+')

  IO.foreach(ARGV[0]) do |line|
    fields = get_fields_from_json(line, ['created_at', 'text'])
    tweet = get_cleaned_tweet(fields['text'])

    rolling_graph.add(fields['created_at'], tweet)

    op = String(rolling_graph.get_average_degree) + "\n"
    output_file.write(op)
  end

  output_file.close
end

