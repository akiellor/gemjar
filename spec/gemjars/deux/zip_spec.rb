require 'gemjars/deux/zip'

include Gemjars::Deux

describe ZipReader do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__))}
  let(:zip_path) { File.join(samples, "single-file.zip") }
  
  it "should yield each entry" do
    zip = ZipReader.new(File.open(zip_path))

    zip.map(&:name).should == ["file"]
  end
end

describe ZipWriter do
  let(:pipe) { IO.pipe }
  let(:reader) { ZipReader.new(pipe[0]) }
  let(:writer) { ZipWriter.new(pipe[1]) }

  it "should create zip entry" do
    writer.add_entry "file"
    writer.close

    reader.map(&:name).should == %w{file}
  end

  it "should create zip entry with content" do
    writer.add_entry "foo", Java::JavaIo::ByteArrayInputStream.new("bar".to_java_bytes).to_io
    writer.close

    reader.map {|e| [e.name, e.read] }.should == [["foo", "bar"]]
  end
end