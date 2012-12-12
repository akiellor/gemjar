require 'digest/sha1'
require 'digest/md5'
require 'nokogiri'

module Ivy
  java_import 'org.apache.ivy.plugins.parser.xml.XmlModuleDescriptorParser'
  java_import 'org.apache.ivy.core.settings.IvySettings'
  java_import 'org.apache.ivy.plugins.resolver.packager.BuiltFileResource'
end

Then /^the response should be a valid ivy xml$/ do
  settings = Ivy::IvySettings.new
  last_response_path = File.expand_path("last_response", Acceptance::Configuration.work_directory)
  url = Java::JavaNet::URL.new("file://" + last_response_path)
  resource = Ivy::BuiltFileResource.new(Java::JavaIo::File.new(last_response_path))
  Ivy::XmlModuleDescriptorParser.instance.parse_descriptor settings, url, resource, true
end

Then /^the response should be a jar with directories:$/ do |expected_directories_string|
  last_response_path = File.expand_path("last_response", Acceptance::Configuration.work_directory)

  actual_directories = `jar -tf #{last_response_path}`.split("\n").sort
  expected_directories = expected_directories_string.split("\n").sort

  actual_directories.should == expected_directories
end

Then /^the response should contain "([^"]*)"$/ do |expected_body|
  last_response_path = File.expand_path("last_response", Acceptance::Configuration.work_directory)
  File.read(last_response_path).should == expected_body
end

Then /^the response should contain the sha1 of "([^"]*)"$/ do |resource|
  actual_sha1 = File.read(File.expand_path("last_response", Acceptance::Configuration.work_directory))

  step "I hit the URL \"#{resource}\""

  expected_sha1 = Digest::SHA1.file(File.expand_path("last_response", Acceptance::Configuration.work_directory)).to_s

  actual_sha1.should == expected_sha1
end

Then /^the response should contain the md5 of "([^"]*)"$/ do |resource|
  actual_md5 = File.read(File.expand_path("last_response", Acceptance::Configuration.work_directory))

  step "I hit the URL \"#{resource}\""

  expected_md5 = Digest::MD5.file(File.expand_path("last_response", Acceptance::Configuration.work_directory)).to_s

  actual_md5.should == expected_md5
end

Then /^the response should be a valid maven pom xml$/ do
  xsd = Nokogiri::XML::Schema(java.lang.Thread.current_thread.get_context_class_loader.getResourceAsStream("maven-v4_0_0.xsd").to_io)
  doc = Nokogiri::XML(File.read(File.expand_path("last_response", Acceptance::Configuration.work_directory)))

  doc.should be_valid_xml xsd
end

Then /^the response should be not found$/ do
  @last_status.should == "404"
end

RSpec::Matchers.define :be_valid_xml do |doc|
  match do |schema|
    doc.validate(schema).empty?
  end
end
