require 'gemjars/deux/transform'

include Gemjars::Deux

describe Transform do
  let(:samples) { File.expand_path("samples", File.dirname(__FILE__)) }
  let(:gem) { File.join(samples, "rspec-2.11.0.gem") }
  
  xit "should transform a gem into a jar" do
    gem_io = File.open(gem)
    jar_r, jar_w = IO.pipe

    Transform.apply gem_io, jar_w

    p Zip.new(jar_r).map(&:to_s)
  end
end

