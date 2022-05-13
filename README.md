# Self Sign Certificate Generator

## Ruby Version:- ruby 2.5.1p57
## OpenSSl Version :- openssl (2.1.0)
## pry (0.14.0)
## rack (2.2.3)
## thor (1.2.1)

This Program have 2 side one is client side another is server side, so in this program what i do is i am generating self sign certificate which is signed by CA and For server i am using **TCPServer**. i am connecting that SSL certificate to that server also checking the Expiry dates of SSL Certificate.

* In one tab
 > we need to run **localhost:3000** here we can able to get the server side information .

* In another tab
 > we need to run **ruby tcp_client.rb** here we were communicating client request with server also in this file we were generating Self sign certificate .
 > We were also checking whether the certificate is expired or not


*Here we were connecting ssl to client

```ruby
ctx = OpenSSL::SSL::SSLContext.new
ctx.min_version = OpenSSL::SSL::TLS1_1_VERSION
ctx.max_version = OpenSSL::SSL::TLS1_2_VERSION

socket = TCPSocket.open(r_host.to_s, r_port.to_i)
ssl_client = OpenSSL::SSL::SSLSocket.new(socket)
ssl_client.connect
```

* Here we were generating a self signed certificate and decrypting ssl certificate to get the details and print results

```ruby
CertificateGenerator.generate
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

```
* Whether certificate is expired or not i am checking that and send message to server

```ruby
if (decryptic_certificate.not_after - Time.now) < r_date_s
  puts "CRITICAL - Certificate expired on #{decryptic_certificate.not_after}"
  exit 2
else
  puts "OK - Certificate will expire on #{decryptic_certificate.not_after}"
end
```
* I also added one sample Certificate and RSA private key .

### Things we can improve ( What i think i can improve )

- I haven't work deeply any webserver yet just for development have used Nginx, but i can learn Apache Webserver also implement my self-signed certificate.
- I can use all above code and create one rails engine so that in future if we need any certficate generator we can implement that.
- What i was thinking that 1st I am going to use ** ruby generate_certificate.rb generate** method to create certificate and key . if we use this then we can able to pass params to create certificate such as country, state, organization name etc.
- the type of encryption that is used is RSA but we can use ECDSA cuz it is becoming increasingly popular due to its security features. now i am just exploring the difference between (RSA vs ECDSA)
