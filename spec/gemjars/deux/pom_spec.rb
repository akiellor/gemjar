require 'spec_helper'
require 'gemjars/deux/pom'

include Gemjars::Deux

describe Pom do
  let(:spec) { mock(:spec, :name => name, :version => Gem::Version.new(version), :runtime_dependencies => runtime_dependencies) }
  let(:runtime_dependencies) { [mock(:dep, :name => "bar", :requirement => Gem::Requirement.new("= 2.0.0"))] }
  let(:pom) { Pom.new(spec) }
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:maven_schema_path) { File.join(samples, "maven-v4_0_0.xsd") }
  let(:name) { "foo" }
  let(:version) { "1.2.0" }
 
  it "should generate pom from spec" do
    specs = mock(:specs)
    specs.should_receive(:minimum_version).with("bar", "= 2.0.0").and_return("1.0.0")

    io = StringIO.new
    
    pom.write_to io, specs

    io.string.should be_valid_xml File.read(maven_schema_path)
    io.string.should have_xpath_value "/xmlns:project/xmlns:modelVersion", "4.0.0"
    io.string.should have_xpath_value "/xmlns:project/xmlns:groupId", "org.rubygems"
    io.string.should have_xpath_value "/xmlns:project/xmlns:artifactId", name
    io.string.should have_xpath_value "/xmlns:project/xmlns:version", version
    io.string.should have_xpath_value "//xmlns:dependency/xmlns:groupId", "org.rubygems"
    io.string.should have_xpath_value "//xmlns:dependency/xmlns:artifactId", "bar"
    io.string.should have_xpath_value "//xmlns:dependency/xmlns:version", "1.0.0"
  end

  context "version translation" do
    let(:specs) { mock(:specs) }
    it "should translate '=' version to maven style'" do
      specs.should_receive(:minimum_version).with("rspec", "2.0.0").and_return("1.0.0")
      
      version = Pom.to_maven_version "rspec", "2.0.0", specs

      version.should == "1.0.0"
    end
  end
end
