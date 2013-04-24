require 'spec_helper'
require 'gemjars/deux/http'
require 'gemjars/deux/streams'

include Gemjars::Deux

describe Http do
  let(:http) { Http.new(executor) }
  let(:executor) { Java::JavaUtilConcurrent::Executors.new_single_thread_executor }

  after(:each) { executor.shutdown_now }

  it "should raise if no block given" do
    expect { http.get("www.example.come") }.to raise_error("No block given")
  end

  it "should get the resource" do
    response = mock(:response, :code => "200")
    response.should_receive(:read_body).
      and_yield("bar")

    Net::HTTP.should_receive(:get_response).
      with(URI.parse("www.example.com")).
      and_yield(response)

    http.get("www.example.com") do |io|
      Streams.read(io).should == "bar"
    end
  end

  ["301", "302"].each do |status|
    it "should follow the location on a #{status}" do
      redirect_response = mock(:response, :code => status, :header => {'location' => "www.example.com/foo"})
      content_response = mock(:response, :code => "200")
      content_response.should_receive(:read_body).
        and_yield("bar")

      Net::HTTP.should_receive(:get_response).
        with(URI.parse("www.example.com")).
        and_yield(redirect_response)

      Net::HTTP.should_receive(:get_response).
        with(URI.parse("www.example.com/foo")).
        and_yield(content_response)

      http.get("www.example.com") do |io|
        Streams.read(io).should == "bar"
      end
    end
  end
end


