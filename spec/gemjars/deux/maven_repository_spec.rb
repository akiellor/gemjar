require 'spec_helper'
require 'gemjars/deux/maven_repository'
require 'timeout'

include Gemjars::Deux

RSpec::Matchers.define :be_an_io_with do |content|
  match do |io|
    Timeout::timeout(1) do
      @out = StringIO.new
      while chunk = io.read(1024)
        @out << chunk
      end
      @out.string == content
    end
  end

  failure_message_for_should do |io|
    "expected io to have content #{content.inspect} but had #{@out.string.inspect}"
  end
end

describe MavenRepository do
  let(:repository) { MavenRepository.new(store) }
  let(:store) { mock(:store) }

  it "should put jar, md5 and sha1 into store" do
    jar_r, jar_w = IO.pipe 
    jar_md5_r, jar_md5_w = IO.pipe 
    jar_sha1_r, jar_sha1_w = IO.pipe 

    store.stub(:put).with("org/rubygems/foo/1/foo-1.jar", :content_type => "application/java-archive") { jar_w }
    store.stub(:put).with("org/rubygems/foo/1/foo-1.jar.md5", :content_type => "text/plain") { jar_md5_w }
    store.stub(:put).with("org/rubygems/foo/1/foo-1.jar.sha1", :content_type => "text/plain") { jar_sha1_w }

    pom_r, pom_w = IO.pipe 
    pom_md5_r, pom_md5_w = IO.pipe 
    pom_sha1_r, pom_sha1_w = IO.pipe 

    store.stub(:put).with("org/rubygems/foo/1/foo-1.pom", :content_type => "application/xml") { pom_w }
    store.stub(:put).with("org/rubygems/foo/1/foo-1.pom.md5", :content_type => "text/plain") { pom_md5_w }
    store.stub(:put).with("org/rubygems/foo/1/foo-1.pom.sha1", :content_type => "text/plain") { pom_sha1_w }

    repository.pipe_to("foo", "1") do |jar, pom|
      jar << "foo\n"
      pom << "foo\n"
    end

    jar_r.should be_an_io_with("foo\n")
    jar_w.should be_closed
    jar_md5_r.should be_an_io_with("d3b07384d113edec49eaa6238ad5ff00")
    jar_md5_w.should be_closed
    jar_sha1_r.should be_an_io_with("f1d2d2f924e986ac86fdf7b36c94bcdf32beec15")
    jar_sha1_w.should be_closed

    pom_r.should be_an_io_with("foo\n")
    pom_w.should be_closed
    pom_md5_r.should be_an_io_with("d3b07384d113edec49eaa6238ad5ff00")
    pom_md5_w.should be_closed
    pom_sha1_r.should be_an_io_with("f1d2d2f924e986ac86fdf7b36c94bcdf32beec15")
    pom_sha1_w.should be_closed
  end
end
