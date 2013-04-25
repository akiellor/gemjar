require 'spec_helper'
require 'gemjars/deux/tar'

include Gemjars::Deux

describe TarReader do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:tar_path) { File.join(samples, "single-file.tar") }
  let(:tgz_path) { File.join(samples, "single-file.tgz") }
 
  it "should yield entries for tar" do
    tar = TarReader.new(Java::JavaIo::FileInputStream.new(tar_path).channel)
    tar.map {|e| [e.name, e.read]}.should == [["foo", "bar\n"]]
  end

  it "should yield entries for a tgz" do
    tgz = TarReader.new(Java::JavaIo::FileInputStream.new(tgz_path).channel, :gzip)
    tgz.map(&:name).should == %w{file}
  end
end
