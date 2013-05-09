require 'spec_helper'
require 'gemjars/deux/maven_repository'
require 'gemjars/deux/streams'
require 'timeout'

include Gemjars::Deux

RSpec::Matchers.define :be_a_channel_with do |content|
  match do |channel|
    Timeout::timeout(1) do
      @out = Streams.read_channel(channel)
      @out == content
    end
  end

  failure_message_for_should do |channel|
    "expected io to have content #{content.inspect} but had #{@out.inspect}"
  end
end

describe MavenRepository do
  let(:repository) { MavenRepository.new(store) }
  let(:store) { mock(:store) }

  it "should put jar, md5 and sha1 into store" do
    jar_r, jar_w = Streams.pipe_channel
    jar_md5_r, jar_md5_w = Streams.pipe_channel 
    jar_sha1_r, jar_sha1_w = Streams.pipe_channel 

    store.stub(:put).with("org/rubygems/foo/1/foo-1.jar", :content_type => "application/java-archive") { jar_w }
    store.stub(:put).with("org/rubygems/foo/1/foo-1.jar.md5", :content_type => "text/plain") { jar_md5_w }
    store.stub(:put).with("org/rubygems/foo/1/foo-1.jar.sha1", :content_type => "text/plain") { jar_sha1_w }

    pom_r, pom_w = Streams.pipe_channel 
    pom_md5_r, pom_md5_w = Streams.pipe_channel 
    pom_sha1_r, pom_sha1_w = Streams.pipe_channel 

    store.stub(:put).with("org/rubygems/foo/1/foo-1.pom", :content_type => "application/xml") { pom_w }
    store.stub(:put).with("org/rubygems/foo/1/foo-1.pom.md5", :content_type => "text/plain") { pom_md5_w }
    store.stub(:put).with("org/rubygems/foo/1/foo-1.pom.sha1", :content_type => "text/plain") { pom_sha1_w }

    repository.pipe_to("foo", "1") do |jar, pom|
      bytes = "foo\n".to_java_bytes
      buffer = Java::JavaNio::ByteBuffer.allocate(bytes.length)
      buffer.put bytes
      buffer.flip
      jar.write buffer
      buffer.rewind
      pom.write buffer
    end

    jar_r.should be_a_channel_with("foo\n")
    jar_w.should_not be_open
    jar_md5_r.should be_a_channel_with("d3b07384d113edec49eaa6238ad5ff00")
    jar_md5_w.should_not be_open
    jar_sha1_r.should be_a_channel_with("f1d2d2f924e986ac86fdf7b36c94bcdf32beec15")
    jar_sha1_w.should_not be_open

    pom_r.should be_a_channel_with("foo\n")
    pom_w.should_not be_open
    pom_md5_r.should be_a_channel_with("d3b07384d113edec49eaa6238ad5ff00")
    pom_md5_w.should_not be_open
    pom_sha1_r.should be_a_channel_with("f1d2d2f924e986ac86fdf7b36c94bcdf32beec15")
    pom_sha1_w.should_not be_open
  end

  it "should delete jar and pom" do
    store.should_receive(:delete_all).with("org/rubygems/foo/1/foo-1.jar",
                                           "org/rubygems/foo/1/foo-1.jar.md5",
                                           "org/rubygems/foo/1/foo-1.jar.sha1",
                                           "org/rubygems/foo/1/foo-1.pom",
                                           "org/rubygems/foo/1/foo-1.pom.md5",
                                           "org/rubygems/foo/1/foo-1.pom.sha1")

    repository.delete_all [Specification.new("foo", "1", "ruby")]
  end
end
