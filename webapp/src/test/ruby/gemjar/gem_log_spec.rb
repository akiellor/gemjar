require 'gemjar/gem_log'

describe Gemjar::GemLog do
  [:ask, :ask_for_password, :ask_yes_no, :choose_from_list, :terminate_interaction].each do |ui_method|
    it "should not support method #{ui_method}" do
      expect { Gemjar::GemLog.new.send(ui_method) }.to raise_error(NoMethodError)
    end
  end

  it "should log info for say" do
    logger = mock(:logger)
    ui = Gemjar::GemLog.new(logger)
    logger.should_receive(:info).with("Some awesome message.")
    ui.say("Some awesome message.")
  end

  it "should log info for alert" do
    logger = mock(:logger)
    ui = Gemjar::GemLog.new(logger)
    logger.should_receive(:info).with("Some awesome message.")
    ui.alert("Some awesome message.")
  end

  it "should log error for alert_error" do
    logger = mock(:logger)
    ui = Gemjar::GemLog.new(logger)
    logger.should_receive(:error).with("Some awesome message.")
    ui.alert_error("Some awesome message.")
  end

  it "should log warn for alert_warning" do
    logger = mock(:logger)
    ui = Gemjar::GemLog.new(logger)
    logger.should_receive(:warn).with("Some awesome message.")
    ui.alert_warning("Some awesome message.")
  end
end
