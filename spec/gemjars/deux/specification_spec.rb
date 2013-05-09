require 'spec_helper'
require 'gemjars/deux/specification'

include Gemjars::Deux

describe Specification do
  subject { Specification.new("foo", "1.2", platform) }

  context "ruby platform" do
    let(:platform) { "ruby" }
    
    its(:gem_uri) { should == "http://rubygems.org/gems/foo-1.2.gem"}
    its(:identifier) { should == "foo-1.2" }
    its(:signature) { should == "5cd314f5c9723993684c380563df642a" }
  end

  context "java platform" do
    let(:platform) { "java" }

    its(:gem_uri) { should == "http://rubygems.org/gems/foo-1.2-java.gem"}
    its(:identifier) { should == "foo-1.2-java" }
    its(:signature) { should == "744e88dc7d418269952d6739d6e3bf7c" }
  end
end
