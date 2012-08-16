require 'gemjar/maven_path'

describe Gemjar::MavenPath do
  context "/org/rubygems/rspec/2.6.0/rspec-2.6.0.pom" do
    subject { Gemjar::MavenPath.parse("/org/rubygems/rspec/2.6.0/rspec-2.6.0.pom") }

    its(:version) { should == "2.6.0" }
    its(:artifact) { should == "rspec" }
    its(:organisation) { should == "org.rubygems" }
    its(:extension) { should == "pom" }
  end

  context "/org/rubygems/rspec/2.6.0/rspec-expectations-2.6.0.pom" do
    subject { Gemjar::MavenPath.parse("/org/rubygems/rspec-expectations/2.6.0/rspec-expectations-2.6.0.pom") }

    its(:version) { should == "2.6.0" }
    its(:artifact) { should == "rspec-expectations" }
    its(:organisation) { should == "org.rubygems" }
    its(:extension) { should == "pom" }
  end
end