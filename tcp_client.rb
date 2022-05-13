#!/usr/bin/env ruby

require "socket"
require 'openssl'
require 'pry'
require_relative 'generate_certificate.rb'

r_host = "localhost"
r_date = 30
r_port = 3000
r_date_s = r_date.to_i * 60 * 60 * 24

ctx = OpenSSL::SSL::SSLContext.new
ctx.min_version = OpenSSL::SSL::TLS1_1_VERSION
ctx.max_version = OpenSSL::SSL::TLS1_2_VERSION

begin

socket = TCPSocket.open(r_host.to_s, r_port.to_i)
ssl_client = OpenSSL::SSL::SSLSocket.new(socket)
ssl_client.connect
encryptic_certificate = File.open("ca-cert.pem").read
decryptic_certificate = OpenSSL::X509::Certificate.new(encryptic_certificate)

certprops = OpenSSL::X509::Name.new(decryptic_certificate.issuer).to_a
issuer = certprops.select { |name, data, type| name == "O" }.first[1]
results = { 
        :valid_on => decryptic_certificate.not_before,
        :valid_until => decryptic_certificate.not_after,
        :issuer => issuer,
        :valid => (ssl_client.verify_result == 0)
      }
puts results 

rescue => e
  puts "CRITICAL - #{e.class} #{e.message}"
  exit 2
end

if (decryptic_certificate.not_after - Time.now) < r_date_s
  puts "CRITICAL - Certificate expired on #{decryptic_certificate.not_after}"
  exit 2
else
  puts "OK - Certificate will expire on #{decryptic_certificate.not_after}"
end
  
socket.puts "Sending data to server"
socket.close_write 
while(line = socket.gets)
  puts line
end 
socket.close
