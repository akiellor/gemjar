require 'spec_helper'
require 'gemjars/deux/specifications'

include Gemjars::Deux

describe Specifications do
  let(:specifications) { Specifications.new(io) }
  let(:io) { Marshal.dump([["zzzzzz", Gem::Version.new("0.0.3"), "ruby"]]) }

  it "should have a single spec" do
    specifications["zzzzz"].should == ["0.0.3"]
  end
end
