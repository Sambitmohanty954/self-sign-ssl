#!/usr/bin/env ruby

  require 'rubygems'
  require 'thor'
  require 'openssl'
  require 'pry'

  DEFAULT_OPTIONS = {
    country: "IN",
    state: "Karnataka",
    org: "sambitindia",
    email: "sammohanty",
    expire_in_days: 30
  }


  class CertificateGenerator < Thor
    class_option :country, :desc => "Country name (2 letter code) [AU]"
    class_option :state, :desc => "State or province name (full name)"
    class_option :org, :desc => "Locality name(eg, city)"
    class_option :email, :desc => "Email address"
    class_option :expire_in_days, :desc => "Expiry data"

    desc "generate", "Generate self signed certificate"
    def self.generate
      key = OpenSSL::PKey::RSA.new(2048)
      subject = ""
      
      subject << "/C=#{options[:country].nil? ? DEFAULT_OPTIONS[:country] : options[:country]}"
      subject << "/ST=#{options[:state].nil? ? DEFAULT_OPTIONS[:state] : options[:state]}"
      subject << "/O=#{options[:org].nil? ?  DEFAULT_OPTIONS[:org]  : options[:org]}"
      subject << "/emailAddress=#{options[:email].nil? ?  DEFAULT_OPTIONS[:email]  : options[:email]}"

      cert = OpenSSL::X509::Certificate.new
      cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
      cert.not_before = Time.now
      cert.not_after = Time.now + DEFAULT_OPTIONS[:expire_in_days] * 24 * 60 * 60
      cert.public_key = key.public_key
      cert.serial = (Time.now.to_f * 10**12).to_i + Random.rand(10000)
      cert.version = 2

      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = cert
      cert.add_extension ef.create_extension("basicConstraints","CA:TRUE", true)
      cert.add_extension ef.create_extension("subjectKeyIdentifier", "hash")
      cert.add_extension ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always")

      cert.sign key, OpenSSL::Digest::SHA256.new
      # _prompt_for_confirmation(msg= "you want to download certificate??") do
        File.open("ca-cert.pem", "w")do |file|
          file.print cert.to_pem
        end
      # end

      # _prompt_for_confirmation(msg= "you want to download private-key??") do |file|
        File.open("ca-key.pem", "w")do |file|
          file.print key.to_pem
        end
      # end
      # puts Hash[cert.subject.to_a.map{|i| [i[0].to_sym, i[1]]}]
      puts cert.to_pem

      puts "Your SSL Certificate download success"
    end
  end

  def _prompt_for_confirmation(msg = "Are you sure you want to continue? (y/n)")
    if yes? msg
      yield
    else
      say "Skiipping", :red
    end
  end

  if $PROGRAM_NAME == __FILE__
    CertificateGenerator.start(ARGV)
  end
