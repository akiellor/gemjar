require 'spec_helper'
require 'gemjars/deux/commands/yank_predicate'

include Gemjars::Deux

describe Commands::YankPredicate do
  it "should match exact versions" do
    predicate = Commands::YankPredicate.new(["rspec", "2.11.0"])
    specs = [
      Specification.new("rspec", "2.11.0", "ruby"),
      Specification.new("rspec", "2.11.0", "java"),
      Specification.new("rspec", "0", "ruby"),
      Specification.new("foo", "2.11.0", "ruby"),
      Specification.new("foo", "0", "ruby")
    ]
    specs.map(&predicate).should == [true, true, false, false, false]
  end

  it "should match when platform matches" do
    predicate = Commands::YankPredicate.new(["platform:java"])
    specs = [
      Specification.new("rspec", "2.11.0", "ruby"),
      Specification.new("rspec", "2.11.0", "java")
    ]
    specs.map(&predicate).should == [false, true]
  end

  it "should match when name matches" do
    predicate = Commands::YankPredicate.new(["name:foo"])
    specs = [
      Specification.new("rspec", "2.11.0", "ruby"),
      Specification.new("foo", "2.11.0", "ruby")
    ]
    specs.map(&predicate).should == [false, true]
  end
end
