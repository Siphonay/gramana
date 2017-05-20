#!/usr/bin/env ruby
# coding: utf-8
# gramana: a Telegram anagram bot
# Written in Ruby by Alexis « Sam » « Siphoné » Viguié
# No license applied

# Load the required gem to communicate with Telegram
require 'telegram/bot'

# Exiting the program if no argument is specified
abort "please specify a telegram bot api token in argument." unless ARGV[0]

# Do a loop to prevent the script from crashing if it can't reach telegram
begin
  # Initialize bot
  Telegram::Bot::Client.run(ARGV[0]) do |gramana_bot|
    # Process each recieved message
    gramana_bot.listen do |message|
      puts "#{message.from.username}: #{message.text}"                                                                                                                                  # For logging purpose, display the text of any recieved message

      # Do various actions depending on the recieved message
      case message.text
      when "/start"                                                                                                                                                                     # If the message is "start",
        puts "user #{message.from.username} started interacting with the bot"                                                                                                           # send a notice to the log and
        gramana_bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}! Please send me a word, and I'll reply with its anagrams if I there are any!")  # explain to the user how the bot works.
      when nil                                                                                                                                                                          # If the message doesn't contain text,
        gramana_bot.api.send_message(chat_id: message.chat.id, text: "Please send me a message with text in it!")                                                                       # tell the user it should.
      else                                                                                                                                                                              # Else,
        word = message.text.split(" ")[0].downcase                                                                                                                                      # Get the first word of the message in lowercase,

        # Building the anagram list
        reply_anagrams = `an -w -m #{word.length} #{word}`                                                                                                                              # call the "an" system command with it,
                           .split("\n")                                                                                                                                                 # make a table of the returned words, separating them with the newlines,
                           .map { |anagram| anagram.downcase.delete("'") }                                                                                                              # make them all lowercase and remove single quotes,
                           .uniq                                                                                                                                                        # delete non-unique words,
                           .delete_if { |anagram| anagram == word }                                                                                                                     # delete the word itself if it is present,

        gramana_bot.api.send_message(chat_id: message.chat.id,                                                                                                                          # Send the result :
                                     text:
                                       if reply_anagrams.size != 0                                                                                                                      # if there is anagrams in the list,
                                         "Anagram#{"s" if reply_anagrams.size > 1} for #{word}:\n#{reply_anagrams.join("\n")}"                                                          # send them to the user, each separated by a new line,
                                       else                                                                                                                                             # else,
                                         "Sorry! No anagrams found for #{word}"                                                                                                         # notify the user.
                                       end)
      end
    end
  end
rescue => error
  # Handling exceptions
  STDERR.puts "got error: #{error}"     # Put what the exception is
  retry                                 # Launch the script again
end
