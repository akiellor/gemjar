require 'fakefs/safe'
require 'fakefs/spec_helpers'
require 'gemjar/file_resource'

describe Gemjar::FileResource do
  include FakeFS::SpecHelpers

  let(:file_path)    { "/tmp/some_file" }
  let(:file_content) { "some content \n inside this file" }

  before do
    FileUtils.mkdir_p(File.dirname(file_path))
    File.open(file_path, "w") { |f| f.write(file_content) }
  end

  subject { Gemjar::FileResource.new(file_path) }

  its(:content) { should == file_content }
  its(:md5)     { should == Digest::MD5.hexdigest(file_content) }
  its(:sha1)    { should == Digest::SHA1.hexdigest(file_content) }
end