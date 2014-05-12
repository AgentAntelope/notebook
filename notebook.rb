#!/usr/bin/env ruby
require 'socket'
require 'sqlite3'

CRLF = "\r\n"

server = TCPServer.new(9292)
database = SQLite3::Database.new('notebook.sqlite3')

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

  response_body = ''

  case [request_method, request_path]
  when ['GET', '/show-notes']
    response_body << '<ul>'
    # show ALL the notes
    database.execute('SELECT * FROM notes') do |(content)|
      response_body << "<li>#{content}</li>"
    end

    response_body << '</ul>'
  else
    response_body << ("request_method: #{request_method}, request_path: #{request_path}, http_version: #{http_version}" + CRLF)
  end

  socket.write response_body
  socket.close
end

