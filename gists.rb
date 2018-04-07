#!/bin/ruby
require 'byebug'

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

@tokens = {}
@current_user = nil
# @tokens = { 'a@b.c' => 'foo' }
# @current_user = 'a@b.c'
@posts = {}

def create_user(email)
  # Assumptions:
  # Any email matching `[something] @ [something] . [something]` is valid
  return "Invalid email address" unless email.match(/.+@.+\..+/)
  return "Email address not available" if @tokens[email]

  token = (0...8).map { (97 + rand(26)).chr }.join
  @tokens[email] = token
  "Remember this: #{token}"
end

def create_session(email, token)
  found = @tokens[email]
  return "Invalid email address or token" unless found && found == token

  @current_user = email
  "Ok"
end

def create_post(text)
  return "No one logged in" unless @current_user
  @posts[@current_user] ||= []
  id = (0...8).map { (97 + rand(26)).chr }.join
  post = {
    :id => id,
    :text => text,
    :time => Time.now,
  }

  @posts[@current_user].unshift(post)
  "Created"
end

def list_posts
  return "No one logged in" unless @current_user

  posts = @posts[@current_user] || []

  posts
    .sort_by{ |p| p[:time] }
    .reverse
    .map { |p| "#{p[:id]} #{p[:time].to_s} #{p[:text]}" }
    .join("\n")
end

def edit_post(id, text)
  return "No one logged in" unless @current_user

  post = @posts[@current_user]
    .detect { |p| p[:id] == id }
  return "Post not found" unless post

  @posts[@current_user] = @posts[@current_user]
    .reject { |p| p[:id] == id }
    .unshift(post.merge({
      :text => text,
      :time => Time.now,
    }))

  "Edited"
end

def delete_post(id)
  return "No one logged in" unless @current_user

  post = @posts[@current_user]
    .detect { |p| p[:id] == id }
  return "Post not found" unless post

  @posts[@current_user] = @posts[@current_user]
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
    puts create_user(input[1])
  when "login"
    puts create_session(input[1], input[2])

  when "post"
    # Assumptions:
    # Text arg will always be present
    # Text will always be surrounded by double-quotes
    # Last quote will not have trailing whitespace
    text = input[1..-1].join(' ').match(/^\s*\"(.*)\"$/).captures.first
    puts create_post(text)

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
