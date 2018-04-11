require_relative './authenticator'
require_relative './post_manager'
require 'socket'

@auth = Authenticator.new
posts = PostManager.new
server = TCPServer.new(8000)

def authenticate(auth_header)
  auth_method, credentials = auth_header.split(' ')
  email, token = credentials.split(':')
  return nil unless auth_method == 'Token'
  @auth.authenticate(email, token) ? email : nil
end

loop do
  client = server.accept
  request = client.gets
  headers = {}

  loop do
    line = client.gets
    break if line == "\r\n"
    header, value = line.split(': ')
    headers[header] = value
  end

  puts "\n"
  puts request
  puts headers

  method, full_path, proto = request.split(' ')
  path, id = full_path.match(/^\/([a-z]*)\/?([0-9a-z]*)?$/)[1..2]

  if proto != 'HTTP/1.1'
    client.close
    next
  end

  case [method, path]

  when ['GET', 'help']
      file = File.read('http_help.html')
      client.puts "HTTP/1.1 200 OK"
      client.puts "Content-Length: #{file.length}\r\n"
      client.puts "Content-Type: text/html\r\n\r\n"
      client.puts file

  when ['POST', 'signup']
      email = client.read(headers["Content-Length"].to_i)
      success, message = @auth.create_user(email)
      if success
        client.puts "HTTP/1.1 200 OK"
        client.puts "Content-Length: #{message.length}\r\n"
        client.puts "Content-Type: text/plain\r\n\r\n"
        client.puts message
      else
        client.puts "HTTP/1.1 400 Bad Request\r\n\r\n"
      end

  when ['GET', 'posts']
      user = authenticate(headers['Authentication'])
      if user
        client.puts "HTTP/1.1 200 OK"
        client.puts "Content-Type: text/json\r\n\r\n"
        client.puts "{\"posts\":["
        posts.list(user).each_with_index do |post, i|
          client.puts "," unless i == 0
          client.write "{\"id\":\"#{post[:id]}\","
          client.write "\"text\":\"#{post[:text]}\","
          client.write "\"time\":\"#{post[:time]}\"}"
        end
        client.puts "\n]}"
      else
        client.puts "HTTP/1.1 400 Bad Request\r\n\r\n"
      end

  when ['POST', 'posts']
      user = authenticate(headers['Authentication'])
      if user
        text = client.read(headers["Content-Length"].to_i)
        posts.create(user, text)
        client.puts "HTTP/1.1 200 OK\r\n\r\n"
      else
        client.puts "HTTP/1.1 400 Bad Request\r\n\r\n"
      end

  when ['PUT', 'posts']
      user = authenticate(headers['Authentication'])
      if user
        text = client.read(headers["Content-Length"].to_i)
        result, message = posts.edit(user, id, text)
        if result
          client.puts "HTTP/1.1 200 OK\r\n\r\n"
        else
          client.puts "HTTP/1.1 400 Bad Request"
          client.puts "Content-Type: text/plain\r\n\r\n"
          client.puts message
        end
      else
        client.puts "HTTP/1.1 400 Bad Request\r\n\r\n"
      end

  when ['DELETE', 'posts']
      user = authenticate(headers['Authentication'])
      if user
        posts.delete(user, id)
        client.puts "HTTP/1.1 200 OK\r\n\r\n"
      else
        client.puts "HTTP/1.1 400 Bad Request\r\n\r\n"
      end

  else
    client.puts "HTTP/1.1 404 Not Found"
  end

  client.close
end
