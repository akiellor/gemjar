$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'rubygems'
require 'gemjar'

run Gemjar::App
