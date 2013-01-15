$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'rubygems'
require 'gemjar'
require 'gemjar/request_log'

app = Rack::Builder.new {
  use Gemjar::RequestLog
  run Gemjar::App
}

run app
