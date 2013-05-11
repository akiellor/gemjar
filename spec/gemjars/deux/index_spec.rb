require 'spec_helper'
require 'gemjars/deux/index'
require 'gemjars/deux/specification'
require 'gemjars/deux/streams'

include Gemjars::Deux

describe Index do
  subject { Index.new(store) }
  let(:store) { mock(:store) }

  context "no indexed gems" do
    before(:each) do
      store.stub(:get).with("index.json.gz").and_return(nil)
    end

    it "should flush every 500 additional gems" do
      store.should_receive(:put).exactly(2).times.and_return(Streams.to_channel(Java::JavaIo::ByteArrayOutputStream.new))

      1000.times {|i| subject.add Specification.new("foo", "1.2.#{i}", "ruby") }
    end

    it { should_not be_handled(Specification.new("zzzzzz", "0.1.0", "ruby")) }
    
    it "should allow for marking specifications as indexed" do
      r, w = Streams.pipe_channel
      spec = Specification.new("foo", "1.2.3", "ruby")
      
      store.stub(:put).with("index.json.gz").and_return(w)

      subject.add spec, :unresolved_dependencies => []
      subject.flush

      json = MultiJson.load(Streams.read_channel(Streams.to_gzip_read_channel(r)), :symbolize_keys => true)
      
      json.should include :spec => {:name => 'foo', :version => '1.2.3', :platform => 'ruby'},
                                                        :metadata => {:unresolved_dependencies => []}
    end

    context "with index on :foo metadata" do
      subject { Index.new(store, :foo) }

      its([:foo]) { should be_empty }

      context "with a spec with :foo" do
        before :each do
          subject.add Specification.new("foo", "1.2.3", "ruby"), :foo => true
        end

        its([:foo]) { should_not be_empty }
      end
    end
  end

  context "indexed zzzzzz 0.1.0 ruby" do
    before(:each) do
      r, w = Streams.pipe_channel
      Thread.new do
        gzip_channel = Streams.to_gzip_write_channel(w)
        gzip_channel.write Streams.to_buffer(MultiJson.dump([{:spec => {:name => "zzzzzz", :version => "0.1.0", :platform => "ruby"}, :metadata => {}}]))
        gzip_channel.close
      end
      store.stub(:get).with("index.json.gz").and_return(r)
    end

    it { should be_handled(Specification.new("zzzzzz", "0.1.0", "ruby")) }
    it { should_not be_handled(Specification.new("foo", "0.1.0", "ruby")) }

    it "should be enumerable" do
      subject.to_a.should == [Specification.new("zzzzzz", "0.1.0", "ruby")]
    end
    
    it "should remove all specified gems from index" do
      r, w = Streams.pipe_channel
      
      store.stub(:put).with("index.json.gz").and_return(w)

      subject.should be_handled(Specification.new("zzzzzz", "0.1.0", "ruby"))
      subject.delete_all [Specification.new("zzzzzz", "0.1.0", "ruby")]
      subject.should_not be_handled(Specification.new("zzzzzz", "0.1.0", "ruby"))
    end

    it "should flush after deleting all specified gems" do
      r, w = Streams.pipe_channel
      store.should_receive(:put).with("index.json.gz").once.and_return(w)

      subject.delete_all [Specification.new("zzzzzz", "0.1.0", "ruby")]
    end
  end 
end

