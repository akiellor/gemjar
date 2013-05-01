require 'spec_helper'
require 'gemjars/deux/workers'
require 'thread'

include Gemjars::Deux

describe Workers do
  let(:queue) { Queue.new }
  let(:worker) { mock(:worker, :done? => true) }
  let(:workers) { Workers.new(queue, [worker]) }

  it "should drain queue when halted" do
    queue << mock(:task)

    workers.halt!

    queue.should be_empty
  end

  it "should wait for workers to be done" do
    worker.should_receive(:done?)

    workers.halt!
  end

  it "should timeout if workers don't become done" do
    Timeout.should_receive(:timeout).and_raise(Timeout::Error)
    worker.stub(:done?).and_return(false)

    expect { workers.halt! }.to raise_error(Timeout::Error)
  end

  it "should timeout after 3 seconds per worker" do
    workers = Workers.new(queue, [mock(:worker), mock(:worker)])
    
    Timeout.should_receive(:timeout).with(6).and_return(nil)

    workers.halt!
  end
end
