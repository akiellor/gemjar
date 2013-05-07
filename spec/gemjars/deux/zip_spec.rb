require 'spec_helper'
require 'gemjars/deux/zip'
require 'gemjars/deux/streams'

include Gemjars::Deux

describe ZipReader do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__))}
  let(:zip_path) { File.join(samples, "single-file.zip") }
  
  it "should yield each entry" do
    zip = ZipReader.new(Java::JavaIo::FileInputStream.new(zip_path).channel)

    zip.map(&:name).should == ["file"]
  end
end

describe ZipWriter do
  let(:pipe) { Streams.pipe_channel }
  let(:reader) { ZipReader.new(pipe[0]) }
  let(:writer) { ZipWriter.new(pipe[1]) }

  it "should create zip entry" do
    writer.add_entry "file"
    writer.close

    reader.map(&:name).should == %w{file}
  end

  it "should create zip entry with content" do
    writer.add_entry "foo", Streams.to_channel(Java::JavaIo::ByteArrayInputStream.new("bar".to_java_bytes))
    writer.close

    reader.map {|e| [e.name, e.read] }.should == [["foo", "bar"]]
  end

  it "should create a zip with a single directory" do
    writer.add_directory "foo/"
    writer.close

    reader.map {|e| e.name }.should == ["foo/"]
  end

  it "should append trailing slash to directory" do
    writer.add_directory "foo"
    writer.close

    reader.map {|e| e.name }.should == ["foo/"]
  end

  it "should not fail when additional directories added" do
    writer.add_directory "foo"
    writer.add_directory "foo"
    writer.close

    reader.map {|e| e.name }.should == ["foo/"]
  end

  it "should make intermediate directories when adding entries" do
    writer.add_entry "foo/bar/baz", Streams.to_channel(Java::JavaIo::ByteArrayInputStream.new("bar".to_java_bytes))
    writer.close

    reader.map {|e| e.name }.should == ["foo/", "foo/bar/", "foo/bar/baz"]
  end
end
