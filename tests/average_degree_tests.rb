
require 'test/unit'
require 'average_degree'

class TestAverageDegree < Test::Unit::TestCase
  attr :rolling_graph

  def setup
    @rolling_graph = RollingHashtagGraph.new
  end

  def teardown
    @rolling_graph = nil
  end

  def test_get_avg_empty
    assert(@rolling_graph.get_average_degree == 0, "Empty graph should have zero average degree")

    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "a sdjlkdsj b")
    assert(@rolling_graph.get_average_degree == 0, "Empty graph should have zero average degree")

    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "a sdjlkdsj b #a")
    assert(@rolling_graph.get_average_degree == 0, "Empty graph should have zero average degree")
  end

  def test_get_avg_single_entry
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#a #b")

    assert(@rolling_graph.get_average_degree == 1, "Wrong avg degree")
  end

  def test_get_avg_with_duplicates
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#a #a #c #b")

    assert(@rolling_graph.get_average_degree == 2, "Wrong avg degree")
  end

  def test_get_avg_multiple_entry
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#a #b")
    @rolling_graph.add("Thu Oct 29 17:51:51 +0000 2015", "#b #c #d")
    @rolling_graph.add("Thu Oct 29 17:51:52 +0000 2015", "#a #a")

    #p @rolling_graph.get_average_degree

    assert(@rolling_graph.get_average_degree == 2, "Wrong avg degree")
  end

  def test_get_avg_over_time_range
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#a #b")
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#b #c")
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#c #d")
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#d #e #f")
    assert(@rolling_graph.get_average_degree == 2, "Wrong avg degree")

    @rolling_graph.add("Thu Oct 29 17:52:50 +0000 2015", "#d #e #f #a")
    assert(@rolling_graph.get_average_degree == 3, "Wrong avg degree")
  end

  def test_get_avg_dup_path
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#a #b")
    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#a #b #c")

    assert(@rolling_graph.get_average_degree == 2, "Wrong avg degree")
  end

  def test_get_avg_vertex_updated_to_new_time
    # set up a graph
    @rolling_graph.add("Thu Oct 29 17:51:40 +0000 2015", "#a #b #c")
    assert(@rolling_graph.get_average_degree == 2, "Wrong avg degree")

    @rolling_graph.add("Thu Oct 29 17:51:50 +0000 2015", "#a #b")
    assert(@rolling_graph.get_average_degree == 2, "Wrong avg degree")

    # add more items at differnt times
    @rolling_graph.add("Thu Oct 29 17:52:20 +0000 2015", "#d #c #e")
    assert(@rolling_graph.get_average_degree == 2.4, "Wrong avg degree")

    @rolling_graph.add("Thu Oct 29 17:51:30 +0000 2015", "#a #d #e")
    assert(@rolling_graph.get_average_degree == 3.2, "Wrong avg degree")

    # add items such that the first item moves out of scope
    @rolling_graph.add("Thu Oct 29 17:52:40 +0000 2015", "#e #f")
    puts @rolling_graph.get_average_degree
    assert(@rolling_graph.get_average_degree == 1.67, "Wrong avg degree")
  end
end
