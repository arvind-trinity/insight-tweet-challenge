# given a tweet file extracts the tweet text and time, cleans the text 
# and counts the number of texts cleaned

require 'json'

def get_cleaned_tweet(tweet)
  if tweet == nil || tweet.empty?
    return ""
  end

  replace_list = {}
  replace_list["\/"] = "/"
  replace_list["\\\\"] = "\\"
  replace_list["\n"] = " "
  replace_list["\t"] = " "
  replace_list["\\'"] = "'"
  replace_list['\\"'] = '"'
  replace_list['\\ '] = ' '

  re = Regexp.new(replace_list.keys.map { |x| Regexp.escape(x) }.join('|'))
  tweet.gsub!(re, replace_list)

  encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => '',        # Use a blank for those replacements
    :UNIVERSAL_NEWLINE_DECORATOR => false       # Always break lines with \n
  }

  return tweet.encode(Encoding.find('ASCII'), encoding_options)
end

def get_fields_from_json(text, field_names)
  hash = JSON.parse(text)

  ret = {}
  field_names.each do |f_n|
    ret[f_n] = hash[f_n]
  end

  return ret
end

def usage 
  puts "#{$0} <tweet_input_file>"
end

if $0 == __FILE__
  if ARGV.count != 2
    usage()
  end

  # read one line at a time from file and call
  # the cleaning funnction to get cleaned output

  clean_count = 0
  output_file = File.open(ARGV[1], 'wb+')
  op = ""

  IO.foreach(ARGV[0]) do |line|
    fields = get_fields_from_json(line, ['created_at', 'text'])

    if fields['created_at'] == nil || fields['text'] == nil
      next
    end

    tweet = get_cleaned_tweet(fields['text'])
    op = tweet + "(timestamp: " + fields['created_at'] + ")\n"
    output_file.write(op)

    if tweet != fields['text']
      clean_count += 1
    end
  end

  op = String(clean_count) + " tweets containted unicode"
  output_file.write(op)
  output_file.close
end

