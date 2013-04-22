require 'spec_helper'
require 'gemjars/deux/pom'

include Gemjars::Deux

describe Pom do
  let(:spec) { mock(:spec, :name => name, :version => Gem::Version.new(version) ) }
  let(:pom) { Pom.new(spec) }
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:maven_schema_path) { File.join(samples, "maven-v4_0_0.xsd") }
  let(:name) { "foo" }
  let(:version) { "1.2.0" }
 
  it "should generate pom from spec" do
    io = StringIO.new
    
    pom.write_to io

    io.string.should be_valid_xml File.read(maven_schema_path)
    io.string.should have_xpath_value "/xmlns:project/xmlns:modelVersion", "4.0.0"
    io.string.should have_xpath_value "/xmlns:project/xmlns:groupId", "org.rubygems"
    io.string.should have_xpath_value "/xmlns:project/xmlns:artifactId", name
    io.string.should have_xpath_value "/xmlns:project/xmlns:version", version
  end
end
