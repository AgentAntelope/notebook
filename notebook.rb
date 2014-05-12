#!/usr/bin/env ruby

require 'cgi'
require 'socket'
require 'sqlite3'
require 'uri'

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
      response_body << "<li>#{CGI.escapeHTML(content)}</li>"
    end

    response_body << '</ul>'

    response_body << %q{
      <form action="/create-note" method="post">
        <input name="content" maxlength="140" autofocus>
        <input type="submit">
      </form>
    }
  when ['POST', '/create-note']
    # write the note
    content_length_header = header_lines.detect {|line| line.start_with?('Content-Length:')}
    content_length = content_length_header.slice(/\d+/).to_i
    request_body = socket.read(content_length)
    params = Hash[URI.decode_www_form(request_body)]
    content = params['content']
    database.execute('INSERT INTO notes VALUES (?)', content)
    response_body << "Posted '#{CGI.escapeHTML(content)}' Please go <a href='/show-notes'>back</a>"
  else
    response_body << ("request_method: #{request_method}, request_path: #{request_path}, http_version: #{http_version}" + CRLF)
  end

  socket.write response_body
  socket.close
end

