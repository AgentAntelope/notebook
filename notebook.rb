#!/usr/bin/env ruby

require 'socket'

CRLF = "\r\n"

server = TCPServer.new(9292)

loop do
  socket = server.accept
  lines = []
  loop do
    line = socket.readline.strip
    break if line.empty?
    lines << line
  end
  request_line, *header_lines = lines
  request_method, request_path, http_version =  request_line.split(' ')

  socket.write 'HTTP/1.1 200 OK' + CRLF
  socket.write 'Content-Type: text/html' + CRLF
  socket.write CRLF
  socket.write "request_method: #{request_method}, request_path: #{request_path}, http_version: #{http_version}" + CRLF
  socket.close
end

