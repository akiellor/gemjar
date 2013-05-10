require 'spec_helper'
require 'gemjars/deux/logger'

include Gemjars::Deux

describe Logger do
  let(:logger) { Logger.new }

  it "should behave like a logger" do
    operations = [:debug,
      :debug?,
      :error,
      :error?,
      :fatal,
      :fatal?,
      :info,
      :info?,
      :warn,
      :warn?]

    operations.each do |r|
      logger.should respond_to r
    end
  end
end
