require 'spec_helper'
require 'gemjars/deux/http'
require 'gemjars/deux/streams'

include Gemjars::Deux

describe Http do
  let(:http) { Http.default }

  it "should raise if no block given" do
    expect { http.get("http://www.example.come") }.to raise_error("No block given")
  end

  it "should get the resource" do
    http.get("http://google.com") do |channel|
      Streams.read_channel(channel).should include "google"
    end
  end
end

