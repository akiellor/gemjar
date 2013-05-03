require 'spec_helper'
require 'gemjars/deux/specified_primer'

include Gemjars::Deux

describe SpecifiedPrimer do
  let(:queue) { Queue.new }
  
  it "should only include the specified gems" do
    gems = ["rails"]
    primer = SpecifiedPrimer.new(gems)
 
    spec1, spec2 = mock(:spec, :name => "rails"), mock(:spec, :name => "foo")

    primer.prime [spec1, spec2], queue

    queue.should have(1).items
    queue.pop.should == spec1
  end
end
