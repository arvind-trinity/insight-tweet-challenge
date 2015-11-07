
require 'test/unit'
require 'tweets_cleaned'

class TestTweetsCleaned < Test::Unit::TestCase

  def test_json_field_extract
    input = "{ \"text\": \"I'm at Terminal de Integra\u00e7\u00e3o do Varadouro in Jo\u00e3o Pessoa, PB https:\/\/t.co\/HOl34REL1a\", \"created_at\": \"Thu Oct 29 17:51:50 +0000 2015\" }"
    output = get_fields_from_json(input, ['text', 'created_at'])

    assert(output["created_at"] == "Thu Oct 29 17:51:50 +0000 2015", "Json extraction failed")
    assert(output["text"] == "I'm at Terminal de Integra\u00e7\u00e3o do Varadouro in Jo\u00e3o Pessoa, PB https:\/\/t.co\/HOl34REL1a", "Json extraction failed")
  end

  def test_tweet_cleaner_empty_text
    input = ""
    output = get_cleaned_tweet(input)

    assert(output == "", "cleaning tweet text failed")
  end
  
  def test_tweet_cleaner
    input = "I\'m at \n Terminal \tde Integra\u00e7\u00e3o do Varadouro in Jo\u00e3o Pessoa, PB https:\/\/t.co\/HOl34REL1a"
    output = get_cleaned_tweet(input)

    count = 0
    if input != output 
      count += 1
    end

    assert(output == "I'm at   Terminal  de Integrao do Varadouro in Joo Pessoa, PB https://t.co/HOl34REL1a", "cleaning tweets failed")

    assert(count == 1, "cleaned count failed")
  end
end

