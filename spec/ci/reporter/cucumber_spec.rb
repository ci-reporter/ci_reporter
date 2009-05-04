# (c) Copyright 2006-2008 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"
require 'ci/reporter/cucumber'

describe "The Cucumber reporter" do
  describe CI::Reporter::CucumberFailure do
    before(:each) do
      @klass = mock("class")
      @klass.stub!(:name).and_return("Exception name")

      @exception = mock("exception")
      @exception.stub!(:class).and_return(@klass)
      @exception.stub!(:message).and_return("Exception message")
      @exception.stub!(:backtrace).and_return(["First line", "Second line"])

      @step = mock("step")
      @step.stub!(:exception).and_return(@exception)

      @cucumber_failure = CI::Reporter::CucumberFailure.new(@step)
    end

    it "should always return true for failure?" do
      @cucumber_failure.should be_failure
    end

    it "should always return false for error?" do
      @cucumber_failure.should_not be_error
    end

    it "should propagate the name as the underlying exception's class name" do
      @step.should_receive(:exception)
      @exception.should_receive(:class)
      @klass.should_receive(:name)

      @cucumber_failure.name.should == "Exception name"
    end

    it "should propagate the message as the underlying exception's message" do
      @step.should_receive(:exception)
      @exception.should_receive(:message)

      @cucumber_failure.message.should == "Exception message"
    end

    it "should propagate and format the exception's backtrace" do
      @step.should_receive(:exception)
      @exception.should_receive(:backtrace)

      @cucumber_failure.location.should == "First line\nSecond line"
    end
  end
end
