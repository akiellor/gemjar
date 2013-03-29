require 'net/http'

When /^I hit the URL "([^"]*)"$/ do |url|
  response = Acceptance::Configuration.server.client.get url
  @last_status = response.status
  response.dump File.expand_path("last_response", Acceptance::Configuration.work_directory)
end

When /^HEAD "([^"]*)"$/ do |url|
  response = Acceptance::Configuration.server.client.head url
  @last_status = response.status
  response.dump File.expand_path("last_response", Acceptance::Configuration.work_directory)
end