require 'spec_helper'
require 'gemjars/deux/priority_queue'
require 'gemjars/deux/specification'
require 'ostruct'

include Gemjars::Deux

describe PriorityQueue do
  let(:queue) { PriorityQueue.new(specs) }
  let(:specs) { mock(:specifications) }

  before(:each) do
    specs.stub(:number_of_releases).and_return(0)
  end

  it "should be empty when queue has no specs" do
    queue.should be_empty
  end

  it "should pop nil when empty" do
    queue.pop.should be_nil
  end

  it "should not be empty when queue has specs" do
    queue << Specification.new("rails", "2", "ruby")

    queue.should_not be_empty
    queue.pop
    queue.should be_empty
  end

  it "should not be empty when queue has forced specs" do
    queue.force Specification.new("rails", "2", "ruby")

    queue.should_not be_empty
    queue.pop
    queue.should be_empty
  end

  it "should prioritize specs with more released versions" do
    specs.stub(:number_of_releases).with("rails").and_return(50)
    specs.stub(:number_of_releases).with("rspec").and_return(10)
    
    queue << Specification.new("rails", "1", "ruby")
    queue << Specification.new("rspec", "2", "ruby")

    queue.pop.name.should == "rails"
    queue.pop.name.should == "rspec"
  end

  it "should prioritize later versions" do
    specs.stub(:number_of_releases).with("rails").and_return(50)
    
    queue << Specification.new("rails", "1", "ruby")
    queue << Specification.new("rails", "2", "ruby")

    queue.pop.version.should == "2"
    queue.pop.version.should == "1"
  end

  it "should prioritize forced specs first" do
    specs.stub(:number_of_releases).with("rails").and_return(50)
    specs.stub(:number_of_releases).with("rspec").and_return(10)
    
    queue << Specification.new("rails", "2", "ruby")
    queue << Specification.new("rails", "3", "ruby")
    queue.force Specification.new("rails", "0", "ruby")
    queue.force Specification.new("rails", "1", "ruby")
    queue << Specification.new("rails", "5", "ruby")

    queue.pop.version.should == "1"
    queue.pop.version.should == "0"
    queue.pop.version.should == "5"
    queue.pop.version.should == "3"
    queue.pop.version.should == "2"
  end
end

