#!/usr/bin/env ruby

require 'socket'
require 'rack'
require 'pry'
 
app = Proc.new do
  ['200', {'Content-Type' => 'text/html'}, ["Hello world! Current time is #{Time.now}"]]
end

server = TCPServer.open 3000
while session = server.accept
  request = session.gets
  puts request
  status, headers, body = app.call({})
  session.print "HTTP/1.1 #{status}\r\n"
  headers.each do |key, value|
    session.print "#{key}: #{value}\r\n"
  end
  session.print "\r\n"
  body.each do |part|
    session.print part
  end
  session.close
end