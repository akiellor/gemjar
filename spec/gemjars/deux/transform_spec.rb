require 'spec_helper'
require 'nokogiri'
require 'gemjars/deux/transform'
require 'set'
require 'tempfile'
require 'bundler'

include Gemjars::Deux

describe Transform do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:gem_file_path) { File.join(samples, "rspec-2.11.0.gem") }
  let(:binscript_gem_file_path) { File.join(samples, "rspec-core-2.11.0.gem") }
  let(:native_gem_file_path) { File.join(samples, "activefacts-0.6.0.gem") }
  let(:duplicate_executable_gem_file_path) { File.join(samples, "hx-0.4.1.gem") }
  let(:unsatisfied_gem_file_path) { File.join(samples, "rspec-2.10.0.gem") }
  let(:maven_schema_path) { File.join(samples, "maven-v4_0_0.xsd") }
  let(:specs) { mock(:specs) }

  before(:each) do
    specs.stub(:satisfactory_spec).with("rspec-core", ["~> 2.10.0"]).and_return(nil)
    specs.stub(:satisfactory_spec).with("rspec-expectations", ["~> 2.10.0"]).and_return(nil)
    specs.stub(:satisfactory_spec).with("rspec-mocks", ["~> 2.10.0"]).and_return(nil)
    specs.stub(:satisfactory_spec).with("rspec-core", ["~> 2.11.0"]).and_return(Specification.new("rspec-core", "1.0.0", "ruby"))
    specs.stub(:satisfactory_spec).with("rspec-expectations", ["~> 2.11.0"]).and_return(Specification.new("rspec-expectations", "1.0.0", "ruby"))
    specs.stub(:satisfactory_spec).with("rspec-mocks", ["~> 2.11.0"]).and_return(Specification.new("rspec-mocks", "1.0.0", "ruby"))
  end

  it "should transform a gem into a jar with binscripts" do
    gem_input_stream = Java::JavaIo::FileInputStream.new(binscript_gem_file_path)

    transform = Transform.new(Specification.new("rspec-core", "2.11.0", "ruby"), gem_input_stream.channel)

    transform.to_mvn(specs) do |h|
      h.success do |jar, pom|
        @success_called = true

        entries = ZipReader.new(jar).map {|e| [e.name, e.read]}

        entries.map {|e| e[0] }.should include "bin/rspec"
      end
    end

    raise unless @success_called
  end

  it "should be on the gem list" do
    gem_input_stream = Java::JavaIo::FileInputStream.new(binscript_gem_file_path)
    jar_out_path = Tempfile.new("rspec-2.11.0").path
    jar_out_file = Java::JavaIo::File.new(jar_out_path)
    jar_out_stream = Java::JavaIo::FileOutputStream.new(jar_out_file)

    transform = Transform.new(Specification.new("rspec-core", "2.11.0", "ruby"), gem_input_stream.channel)

    transform.to_mvn(specs) do |h|
      h.success do |jar, pom|
        Streams.copy_channel jar, jar_out_stream.channel
      end
    end

    Bundler.with_clean_env do
      old_classpath = ENV["CLASSPATH"]
      old_gem_home = ENV["GEM_HOME"]
      old_gem_path = ENV["GEM_PATH"]
      ENV["CLASSPATH"] = jar_out_path
      ENV["GEM_HOME"] = nil
      ENV["GEM_PATH"] = nil

      `jruby -S gem list`.should include "rspec-core"

      ENV["CLASSPATH"] = old_classpath
      ENV["GEM_HOME"] = old_gem_home
      ENV["GEM_PATH"] = old_gem_path
    end
  end

  it "should transform a gem into a jar" do
    gem_input_stream = Java::JavaIo::FileInputStream.new(gem_file_path)

    transform = Transform.new(Specification.new("rspec", "2.11.0", "ruby"), gem_input_stream.channel)

    transform.to_mvn(specs) do |h|
      h.success do |jar, pom|
        @success_called = true

        entries = ZipReader.new(jar).map {|e| [e.name, e.read]}

        Set.new(entries.map {|e| e[0] }).should == Set.new(%w{
          gems/
          gems/rspec-2.11.0/
          gems/rspec-2.11.0/lib/
          gems/rspec-2.11.0/lib/rspec/
          gems/rspec-2.11.0/lib/rspec/version.rb
          gems/rspec-2.11.0/lib/rspec.rb
          gems/rspec-2.11.0/License.txt
          gems/rspec-2.11.0/README.md
          specifications/
          specifications/rspec-2.11.0.gemspec
        })

        version = entries.detect {|e| e[0] == "gems/rspec-2.11.0/lib/rspec/version.rb" }
        version.should == ["gems/rspec-2.11.0/lib/rspec/version.rb", "module RSpec # :nodoc:\n  module Version # :nodoc:\n    STRING = '2.11.0'\n  end\nend\n"]
      end
    end

    raise unless @success_called
  end

  it "should transform a gem into a pom file" do
    gem_input_stream = Java::JavaIo::FileInputStream.new(gem_file_path)

    transform = Transform.new(Specification.new("rspec", "2.11.0", "ruby"), gem_input_stream.channel)
    transform.to_mvn(specs) do |h|
      h.success do |jar, pom|
        @success_called = true
        Streams.read_channel(pom.channel).should be_valid_xml(File.read(maven_schema_path))
      end
    end

    raise unless @success_called
  end  

  it "should report native extensions" do
    gem_channel = Java::JavaIo::FileInputStream.new(native_gem_file_path).channel

    transform = Transform.new(Specification.new("activefacts", "0.6.0", "ruby"), gem_channel)
    transform.to_mvn(specs) do |h|
      h.native do |extensions|
        @native_called = true
        extensions.should == ["lib/activefacts/cql/Rakefile"]
      end
    end

    raise unless @native_called
  end

  it "should report unsatisfied dependencies" do
    gem_channel = Java::JavaIo::FileInputStream.new(unsatisfied_gem_file_path).channel

    transform = Transform.new(Specification.new("rspec", "2.10.0", "ruby"), gem_channel)
    transform.to_mvn(specs) do |h|
      h.unsatisfied_dependencies do |deps|
        deps.should == [["rspec-core", ["~> 2.10.0"]], ["rspec-expectations", ["~> 2.10.0"]], ["rspec-mocks", ["~> 2.10.0"]]]
        @unsatisfied_called = true
      end
    end

    raise unless @unsatisfied_called
  end

  it "should successfully transform gem with duplicate executable entries in gemspec" do
    gem_channel = Java::JavaIo::FileInputStream.new(duplicate_executable_gem_file_path).channel

    transform = Transform.new(Specification.new("hx", "0.4.1", "ruby"), gem_channel)
    transform.to_mvn(specs) do |h|
      h.success do
        @success_called = true
      end
    end

    raise unless @success_called
  end
end
