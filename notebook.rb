#!/usr/bin/env ruby

require 'socket'

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

  puts "request_method: #{request_method}, request_path: #{request_path}, http_version: #{http_version}"
end

