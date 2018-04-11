require_relative './post_manager'
require_relative './authenticator'

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

posts = PostManager.new
auth = Authenticator.new
current_user = nil

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
    success, message = auth.create_user(input[1])
    puts message
  when "login"
    current_user = input[1] if auth.authenticate(input[1], input[2])
    puts message

  when "post", "list", "edit", "del"
    if current_user
      case command
      when "post"
        text = get_input_string(input, 1, -1)
        posts.create(current_user, text)
        puts "Ok"

      when "list"
        puts posts.list(current_user)
          .map { |p| "#{p[:id]} #{p[:time].to_s} #{p[:text]}" }
          .join("\n")

      when "edit"
        text = get_input_string(input, 2, -1)
        puts posts.edit(current_user, input[1], text)

      when "del"
        puts posts.delete(current_user, input[1])
      end
    else
      puts "No one logged in"
    end

  else
    puts "Unrecognized command"
  end
end

puts "goodbye!"

