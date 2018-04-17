require_relative '../services/authenticator'
require_relative '../services/post_manager'
require 'socket'
require 'byebug'

class HttpService

  def initialize
    @auth = Authenticator.new
    @posts = PostManager.new
    @server = TCPServer.new(8000)
    @idem_tokens = {}
  end

  def run
    loop do
      @client = @server.accept
      handle_request
      @client.close
    end
  end

  private

  def handle_request
    method, path, id, proto = read_request
    headers = read_headers
    return if proto != 'HTTP/1.1'

    case [method, path]

    when ['GET', 'help']
      file = File.read(File.expand_path('../assets/http_help.html', File.dirname(__FILE__)))
      respond_200('text/html', file)

    when ['POST', 'signup']
      email = @client.read(headers["Content-Length"].to_i)
      success, message = @auth.create_user(email)
      success ? respond_200('text/plain', message) : respond_400

    when ['GET', 'posts']
      user = authenticate(headers['Authentication'])
      if user
        @client.puts "HTTP/1.1 200 OK"
        @client.puts "Content-Type: text/json\r\n"
        @client.puts "{\"posts\":["
        @posts.list(user).each_with_index do |post, i|
          @client.puts "," unless i == 0
          @client.write "{\"id\":\"#{post[:id]}\","
          @client.write "\"text\":\"#{post[:text]}\","
          @client.write "\"time\":\"#{post[:time]}\"}"
        end
        @client.puts "\n]}"
      else
        respond_400
      end

    when ['POST', 'posts']
      user = authenticate(headers['Authentication'])
      if user
        respond_200 && return if already_seen(user, headers['Idempotency Token'])
        text = @client.read(headers["Content-Length"].to_i)
        @posts.create(user, text)
        respond_200
      else
        respond_400
      end

    when ['PUT', 'posts']
      user = authenticate(headers['Authentication'])
      if user
        respond_200 && return if already_seen(user, headers['Idempotency Token'])
        text = @client.read(headers["Content-Length"].to_i)
        result, message = @posts.edit(user, id, text)
        if result
          respond_200
        else
          respond_400('text/plain', message)
        end
      else
        respond_400
      end

    when ['DELETE', 'posts']
      user = authenticate(headers['Authentication'])
      if user
        @posts.delete(user, id)
        respond_200
      else
        respond_400
      end

    else
      respond('404 Not Found')
    end
  end

  def read_request
    method, full_path, proto = @client.gets.split(' ')
    path, id = full_path.match(/^\/([a-z]*)\/?([0-9a-z]*)?$/)[1..2]
    puts method, full_path
    [method, path, id, proto]
  end

  def read_headers
    headers = {}
    loop do
      line = @client.gets
      break if line == "\r\n"
      header, value = line.split(': ')
      headers[header] = value.chomp
    end
    puts headers
    headers
  end

  def authenticate(auth_header)
    return nil unless auth_header
    auth_method, credentials = auth_header.split(' ')
    return nil unless auth_method && credentials
    return nil unless auth_method == 'Token'
    email, token = credentials.split(':')
    return nil unless email && token
    return nil unless @auth.authenticate(email, token)

    email
  end

  def already_seen(user, idem_token)
    return true if @idem_tokens[user] && @idem_tokens[user].include?(idem_token)
    (@idem_tokens[user] ||= []).unshift(idem_token)
    false
  end

  def respond_200(type='text/plain', body='')
    respond('200 OK', type, body)
  end

  def respond_400(type='text/plain', body='')
    respond('400 Bad Request', type, body)
  end

  def respond(status, type='text/plan', body='')
    @client.puts "HTTP/1.1 #{status}"
    @client.puts "Content-Length: #{body.length}"
    @client.puts "Content-Type: #{type}"
    @client.puts
    @client.write body
  end

end

HttpService.new.run
