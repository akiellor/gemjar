require 'spec_helper'
require 'gemjars/deux/unhandled_primer'
require 'thread'

include Gemjars::Deux

describe UnhandledPrimer do
  let(:queue) { Queue.new }
  let(:primer) { UnhandledPrimer.new(index) }
  let(:index) { mock(:index) }

  it "should prime queue with unhandled specs" do
    spec1, spec2 = mock(:spec), mock(:spec)
    index.stub(:handled?).with(spec1).and_return(false)
    index.stub(:handled?).with(spec2).and_return(true)

    primer.prime [spec1, spec2], queue

    queue.should have(1).items
    queue.pop.should == spec1
  end
end
