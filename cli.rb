#!/bin/ruby
require 'byebug'
require_relative './session_manager'
require_relative './post_manager'

def print_help
  puts <<-HELP
help                              print this message
signup [email address]            sign up a new user (prints a token)
login  [email address] [token]    login as an existing user
post   "some content"             create a new post
list                              list the user's posts
edit   [post id] "new content"    edit a post
del    [post id]                  delete a post
HELP
end

@sessions = SessionManager.new
@posts = PostManager.new

def get_input_string(input, start, finish)
  # Text arg will always be present
  # Text will always be surrounded by double-quotes
  # Last quote will not have trailing whitespace
  input[start..finish].join(' ').match(/^\s*\"(.*)\"$/).captures.first
end

loop do
  print "> "
  # Assumptions:
  # Commands and args are delimited by whitespace
  input = gets.chomp.split(' ')
  command = input[0]

  case command
  when "quit" then break
  when "help" then print_help

  when "signup"
    puts @sessions.create_user(input[1])
  when "login"
    puts @sessions.create_session(input[1], input[2])

  when "post", "list", "edit", "del"
    user = @sessions.current_user
    if user
      case command
      when "post"
        text = get_input_string(input, 1, -1)
        puts @posts.create(user, text)

      when "list"
        puts @posts.list(user)

      when "edit"
        text = get_input_string(input, 2, -1)
        puts @posts.edit(user, input[1], text)

      when "del"
        puts @posts.delete(user, input[1])
      end
    else
      puts "No one logged in"
    end

  else
    puts "Unrecognized command"
  end
end

puts "goodbye!"

