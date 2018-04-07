#!/bin/ruby
require 'byebug'
require_relative './session_manager'

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

@posts = {}
@sessions = SessionManager.new

def create_post(user, text)
  @posts[user] ||= []
  id = (0...8).map { (97 + rand(26)).chr }.join
  post = {
    :id => id,
    :text => text,
    :time => Time.now,
  }
  @posts[user].unshift(post)
  "Created"
end

def list_posts
  return "No one logged in" unless @sessions.logged_in?
  posts = @posts[@sessions.current_user] || []
  posts
    .sort_by{ |p| p[:time] }
    .reverse
    .map { |p| "#{p[:id]} #{p[:time].to_s} #{p[:text]}" }
    .join("\n")
end

def edit_post(id, text)
  return "No one logged in" unless @sessions.logged_in?
  post = @posts[@sessions.current_user]
    .detect { |p| p[:id] == id }
  return "Post not found" unless post

  @posts[@sessions.current_user] = @posts[@sessions.current_user]
    .reject { |p| p[:id] == id }
    .unshift(post.merge({
      :text => text,
      :time => Time.now,
    }))

  "Edited"
end

def delete_post(id)
  return "No one logged in" unless @sessions.logged_in?
  post = @posts[@sessions.current_user]
    .detect { |p| p[:id] == id }
  return "Post not found" unless post

  @posts[@sessions.current_user] = @posts[@sessions.current_user]
    .reject { |p| p[:id] == id }

  "Deleted"
end

loop do
  print "> "
  # Assumptions:
  # Commands and args are delimited by whitespace
  input = gets.chomp.split(' ')

  case input[0]
  when "quit"
    break
  when "help"
    print_help
  when "signup"
    puts @sessions.create_user(input[1])
  when "login"
    puts @sessions.create_session(input[1], input[2])

  when "post"
    user = @sessions.current_user
    if user
      # Text arg will always be present
      # Text will always be surrounded by double-quotes
      # Last quote will not have trailing whitespace
      text = input[1..-1].join(' ').match(/^\s*\"(.*)\"$/).captures.first
      puts create_post(user, text)
    else
      puts "No one logged in"
    end

  when "list"
    puts list_posts

  when "edit"
    # Assumption:
    # Text arg will always be present
    # Text will always be surrounded by double-quotes
    # Last quote will not have trailing whitespace
    text = input[2..-1].join(' ').match(/^\s*\"(.*)\"$/).captures.first
    puts edit_post(input[1], text)

  when "del"
    puts delete_post(input[1])

  else
    puts "Unrecognized command"
  end
end

puts "goodbye!"
