#!/usr/bin/env ruby
# coding: utf-8
# gramana: a Telegram anagram bot
# Written in Ruby by Alexis « Sam » « Siphoné » Viguié
# No license applied

require 'telegram/bot'

abort "please specify a telegram bot api token in argument." unless ARGV[0]

begin
  Telegram::Bot::Client.run(ARGV[0]) do |gramana_bot|
    gramana_bot.listen do |message|
      puts "#{message.from.username}: #{message.text}"
      
      case message.text
      when "/start"
        puts "user #{message.from.username} started interacting with the bot"
        gramana_bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}! Please send me a word, and I'll reply with its anagrams if I there are any!")
      when ""
        gramana_bot.api.send_message(chat_id: message.chat.id, text: "Please send me a message with text in it!")
      else 
        word = message.text.split(" ")[0].downcase
        
        reply_anagrams = `an -w -m #{word.length} #{word}`
                           .split("\n")
                           .map { |anagram| anagram.downcase }
                           .uniq
                           .delete_if { |anagram| anagram == word }
        
        gramana_bot.api.send_message(chat_id: message.chat.id,
                                     text:
                                       if reply_anagrams.size != 0
                                         "Sorry! No anagrams found for #{word}"
                                       else
                                         "Anagram#{"s" if reply_anagrams.size > 1} for #{word}:\n#{reply_anagrams.join("\n")}"
                                       end)
      end
    end
  end
rescue => error
  STDERR.puts "got error: #{error}"
  retry
end
