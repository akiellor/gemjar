require 'spec_helper'
require 'gemjars/deux/binscript'

include Gemjars::Deux

describe Binscript do
  let(:spec) { mock(:spec, :name => "rails") }
  it "should load the right binscript for spec" do
    binscript = Binscript.new(spec, "railties")
    binscript.to_s.should include "#!/usr/bin/env ruby"
    binscript.to_s.should include "load Gem.bin_path('rails', 'railties', version)"
  end
end
