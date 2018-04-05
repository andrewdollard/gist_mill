#!/bin/ruby


loop do
  print "> "
  command = gets.chomp
  break if command == "quitn"
  puts "You entered: #{command}"
end

puts "done."
