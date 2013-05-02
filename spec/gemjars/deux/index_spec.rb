require 'spec_helper'
require 'gemjars/deux/index'
require 'gemjars/deux/specification'
require 'gemjars/deux/streams'

include Gemjars::Deux

describe Index do
  class MessageSink
    def method_missing *args, &block
    end
  end

  subject { Index.new(store) }
  let(:store) { mock(:store) }

  context "no indexed gems" do
    before(:each) do
      store.stub(:get).with("index.json").and_return(nil)
    end

    it "should flush every 500 additional gems" do
      store.should_receive(:put).exactly(2).times.and_return(MessageSink.new)

      1000.times {|i| subject.add Specification.new("foo", "1.2.#{i}", "ruby") }
    end

    it { should_not be_handled(Specification.new("zzzzzz", "0.1.0", "ruby")) }
    
    it "should allow for marking specifications as indexed" do
      r, w = Streams.pipe_channel
      spec = Specification.new("foo", "1.2.3", "ruby")
      
      store.stub(:put).with("index.json").and_return(w)

      subject.add spec, :unresolved_dependencies => []
      subject.flush

      JSON.load(Streams.read_channel(r), nil, :symbolize_names => true).should include :spec => {:name => 'foo', :version => '1.2.3', :platform => 'ruby'},
                                                        :metadata => {:unresolved_dependencies => []}
    end
  end

  context "indexed zzzzzz 0.1.0 ruby" do
    before(:each) do
      channel = Streams.to_channel(Java::JavaIo::ByteArrayInputStream.new(JSON.dump([{:spec => {:name => "zzzzzz", :version => "0.1.0", :platform => "ruby"}, :metadata => {}}]).to_java_bytes))
      store.stub(:get).with("index.json").and_return(channel)
    end

    it { should be_handled(Specification.new("zzzzzz", "0.1.0", "ruby")) }
    it { should_not be_handled(Specification.new("foo", "0.1.0", "ruby")) }
  end 
end

