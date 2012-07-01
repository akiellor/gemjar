require 'net/http'

When /^I hit the URL "([^"]*)"$/ do |url|
  File.open(File.expand_path("last_response", Acceptance::Configuration.work_directory), 'w') do |out|
    Net::HTTP.get_response(URI.parse("http://localhost:8080#{url}")) do |response|
      response.read_body do |segment|
        out << segment
      end
    end
  end
end