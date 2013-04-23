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
      store.stub(:get).with("index.yml").and_return(nil)
    end

    it { should_not be_handled(Specification.new("zzzzzz", "0.1.0", "ruby")) }
    
    it "should allow for marking specifications as indexed" do
      r, w = Streams.pipe
      spec = Specification.new("foo", "1.2.3", "ruby")
      
      store.stub(:put).with("index.yml").and_return(w)

      subject.add spec

      YAML.load(r).should include spec 
    end
  end

  context "indexed zzzzzz 0.1.0 ruby" do
    before(:each) do
      store.stub(:get).with("index.yml").and_return(StringIO.new(YAML.dump([Specification.new("zzzzzz", "0.1.0", "ruby")])))
    end

    it { should be_handled(Specification.new("zzzzzz", "0.1.0", "ruby")) }
    it { should_not be_handled(Specification.new("foo", "0.1.0", "ruby")) }
  end 
end

