require 'gemjars/deux/zip'

include Gemjars::Deux

describe ZipReader do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__))}
  let(:zip_path) { File.join(samples, "single-file.zip") }
  
  it "should yield each entry" do
    zip = ZipReader.new(File.open(zip_path))

    zip.map(&:to_s).should == ["file"]
  end
end
