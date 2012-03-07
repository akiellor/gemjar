$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'gemjar'

run RubyGems::App
