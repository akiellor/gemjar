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