require 'gemjars/deux/transform'

include Gemjars::Deux

describe Transform do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:gem_file_path) { File.join(samples, "rspec-2.11.0.gem") }
  
  xit "should transform a gem into a jar" do
    gem_io = File.open(gem_file_path)
    jar_r, jar_w = IO.pipe

    Transform.apply gem_io, jar_w

    Zip.new(jar_r).map(&:to_s).should == %w{
      bin/ruby_noexec_wrapper
      gems/rspec-2.11.0
      gems/rspec-2.11.0/lib
      gems/rspec-2.11.0/lib/rspec
      gems/rspec-2.11.0/lib/rspec/version.rb
      gems/rspec-2.11.0/lib/rspec.rb
      gems/rspec-2.11.0/License.txt
      gems/rspec-2.11.0/README.md
      specifications/rspec-2.11.0.gemspec
    }
  end
end

