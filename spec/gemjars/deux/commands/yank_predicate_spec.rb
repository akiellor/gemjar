require 'spec_helper'
require 'gemjars/deux/commands/yank_predicate'

include Gemjars::Deux

describe Commands::YankPredicate do
  it "should match exact versions" do
    predicate = Commands::YankPredicate.new(["rspec", "2.11.0"])
    specs = [
      {:spec => {:name => "rspec", :version => "2.11.0", :platform => "ruby"}},
      {:spec => {:name => "rspec", :version => "2.11.0", :platform => "java"}},
      {:spec => {:name => "rspec", :version => "0", :platform => "ruby"}},
      {:spec => {:name => "foo", :version => "2.11.0", :platform => "ruby"}},
      {:spec => {:name => "foo", :version => "0", :platform => "ruby"}}
    ]
    specs.map(&predicate).should == [true, true, false, false, false]
  end
end
