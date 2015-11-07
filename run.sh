#!/usr/bin/env bash

ruby ./src/tweets_cleaned.rb ./tweet_input/tweets.txt ./tweet_output/ft1.txt
ruby -I./src ./src/average_degree.rb ./tweet_input/tweets.txt ./tweet_output/ft2.txt

