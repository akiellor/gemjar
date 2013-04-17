require 'gemjars/deux/tar'

include Gemjars::Deux

describe Tar do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:tar_path) { File.join(samples, "single-file.tar") }
 
  it "should yield entries for tar" do
    tar = Tar.new(File.open(tar_path))
    tar.map(&:name).should == %w{file}
  end
end
