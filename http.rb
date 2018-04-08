require 'socket'
require 'byebug'

server = TCPServer.new(8000)
loop do
  client = server.accept
  request = client.gets
  headers = []
  loop do
    line = client.gets
    break if line == "\r\n"
    headers << line
  end

  path = request.split(' ')[1]

  case path
  when '/signup'
    puts 'signup requested'
  end

  client.puts "HTTP/1.1 200 OK"
  client.close


end
