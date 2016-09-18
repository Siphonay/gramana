#!/usr/bin/env ruby
# coding: utf-8
# gramana: a Telegram anagram bot
# Written in Ruby by Alexis « Sam » « Siphoné » Viguié on the 18-09-2016
# No license applied

# Loading the required gem to make use of Telegram's bot API
require 'telegram_bot'

# Exiting the program if no argument is specified
abort "please specify a telegram bot api token in argument." unless ARGV[0]

# Use the token passed in argument
gramana = TelegramBot.new(token: ARGV[0])

# Processing every message the bot recieves
gramana.get_updates(fail_silently: true) do |message|
  puts "got message: #{message.text}"                           # Display in stdout the latest message recieved
  # Build the word to search an anagram for
  word = if message.text                                        # If the sent message isn't empty,
           message.text.split(" ")[0].downcase                  # get the message's first word to search its anagrams.
         else                                                   # If it is,
           "a"                                                  # get a generic word that won't return anything.
         end

  # Building the reply
  message.reply do |reply|
    reply_anagrams = `an -w -m #{word.length} #{word}`                  # Calls the "an" command to find anagrams of words of the same lenght as the argument word
                     .split("\n")                                       # Split the command output in order to process it as an array
                     .map { |anagram| anagram.downcase }                # Lowercase all found anagrams
                     .uniq                                              # Remove duplicates
                     .delete_if { |anagram| anagram == word }           # If present, delete the original word from the results

    # Building the string                 
    reply.text = if reply_anagrams.size != 0                            # If the anagram list isn't empty,
                   "anagrams for #{word}: #{reply_anagrams.join(" ")}"  # add them all to the message as words separated by spaces.
                 else                                                   # If it is,
                   "no anagrams found."                                 # report it.
                 end

    puts "sending message: #{reply.text}"                               # Display in stdout the next message that will be sent
    reply.send_with(gramana)                                            # Sending the reply
  end
end

# Sending an error code and message if the message loop is exited somehow
abort "this should not have happened."
