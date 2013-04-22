require 'spec_helper'
require 'nokogiri'
require 'gemjars/deux/transform'
require 'set'

include Gemjars::Deux

describe Transform do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:gem_file_path) { File.join(samples, "rspec-2.11.0.gem") }
  let(:maven_schema_path) { File.join(samples, "maven-v4_0_0.xsd") }
  let(:specs) { mock(:specs) }

  before(:each) do
    specs.should_receive(:minimum_version).with("rspec-core", "~> 2.11.0").and_return("1.0.0")
    specs.should_receive(:minimum_version).with("rspec-expectations", "~> 2.11.0").and_return("1.0.0")
    specs.should_receive(:minimum_version).with("rspec-mocks", "~> 2.11.0").and_return("1.0.0")
  end
  
  it "should transform a gem into a jar" do

    gem_io = File.open(gem_file_path)

    jar, pom = Transform.new("rspec", "2.11.0", gem_io).to_mvn(specs)

    entries = ZipReader.new(jar).map {|e| [e.name, e.read]}

    Set.new(entries.map {|e| e[0] }).should == Set.new(%w{
      gems/rspec-2.11.0/lib/rspec/version.rb
      gems/rspec-2.11.0/lib/rspec.rb
      gems/rspec-2.11.0/License.txt
      gems/rspec-2.11.0/README.md
      specifications/rspec-2.11.0.gemspec
    })

    version = entries.detect {|e| e[0] == "gems/rspec-2.11.0/lib/rspec/version.rb" }
    version.should == ["gems/rspec-2.11.0/lib/rspec/version.rb", "module RSpec # :nodoc:\n  module Version # :nodoc:\n    STRING = '2.11.0'\n  end\nend\n"]
  end

  it "should transform a gem into a pom file" do
    gem_io = File.open(gem_file_path)

    jar, pom = Transform.new("rspec", "2.11.0", gem_io).to_mvn(specs)

    Streams.read(pom).should be_valid_xml(File.read(maven_schema_path))
  end  
end


