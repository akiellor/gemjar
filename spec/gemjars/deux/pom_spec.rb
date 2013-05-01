require 'spec_helper'
require 'gemjars/deux/pom'
require 'gemjars/deux/specification'

include Gemjars::Deux

describe Pom do
  let(:spec) { mock(:spec, :name => name, :version => Gem::Version.new(version), :runtime_dependencies => runtime_dependencies) }
  let(:runtime_dependencies) { [mock(:dep, :name => "bar", :requirement => Gem::Requirement.new("= 2.0.0"))] }
  let(:pom) { Pom.new(spec, specs) }
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:maven_schema_path) { File.join(samples, "maven-v4_0_0.xsd") }
  let(:name) { "foo" }
  let(:version) { "1.2.0" }
  let(:specs) { mock(:specs) }
 
  it "should generate pom from spec" do
    specs.should_receive(:satisfactory_spec).with("bar", ["= 2.0.0"]).and_return(Specification.new("bar", "1.0.0", "ruby"))

    pom_string = Streams.read_channel(pom.channel)
    
    pom_string.should be_valid_xml File.read(maven_schema_path)
    pom_string.should have_xpath_value "/xmlns:project/xmlns:modelVersion", "4.0.0"
    pom_string.should have_xpath_value "/xmlns:project/xmlns:groupId", "org.rubygems"
    pom_string.should have_xpath_value "/xmlns:project/xmlns:artifactId", name
    pom_string.should have_xpath_value "/xmlns:project/xmlns:version", version
    pom_string.should have_xpath_value "//xmlns:dependency/xmlns:groupId", "org.rubygems"
    pom_string.should have_xpath_value "//xmlns:dependency/xmlns:artifactId", "bar"
    pom_string.should have_xpath_value "//xmlns:dependency/xmlns:version", "1.0.0"
  end

  context "missing version" do
    let(:specs) { mock(:specs) }
    
    it "should not be satisfied" do
      specs.stub(:satisfactory_spec).with("bar", ["= 2.0.0"]).and_return(nil)
      
      pom.unsatisfied_dependencies.should == [["bar", ["= 2.0.0"]]]
    end
  end
end
