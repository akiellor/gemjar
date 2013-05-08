require 'spec_helper'
require 'gemjars/deux/specification'

include Gemjars::Deux

describe Specification do
  subject { Specification.new("foo", "1.2", platform) }

  context "ruby platform" do
    let(:platform) { "ruby" }
    
    its(:gem_uri) { should == "http://rubygems.org/gems/foo-1.2.gem"}
    its(:identifier) { should == "foo-1.2" }
  end

  context "java platform" do
    let(:platform) { "java" }

    its(:gem_uri) { should == "http://rubygems.org/gems/foo-1.2-java.gem"}
    its(:identifier) { should == "foo-1.2-java" }
  end
end
