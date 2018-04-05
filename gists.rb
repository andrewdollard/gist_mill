#!/bin/ruby

def print_help
  puts "help: print this message"
  puts "sign-up [email address]: sign up a new user"
end

loop do
  print "> "
  input = gets.chomp.split(' ')

  case input[0]
  when "quit"
    break
  when "help"
    print_help
  when "sign-up"
  end
end

puts "goodbye!"
