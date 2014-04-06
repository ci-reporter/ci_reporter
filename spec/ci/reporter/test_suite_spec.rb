# Copyright (c) 2006-2013 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"
require 'rexml/document'

describe "A TestSuite" do
  before(:each) do
    @suite = CI::Reporter::TestSuite.new("example suite")
  end

  it "should collect timings when start and finish are invoked in sequence" do
    @suite.start
    @suite.finish
    @suite.time.should >= 0
  end

  it "should aggregate tests" do
    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("example test")
    @suite.finish
    @suite.tests.should == 1
  end

  it "should stringify the name for cases when the object passed in is not a string" do
    name = Object.new
    def name.to_s; "object name"; end
    CI::Reporter::TestSuite.new(name).name.should == "object name"
  end

  it "should indicate number of failures and errors" do
    failure = double("failure")
    failure.stub(:failure?).and_return true
    failure.stub(:error?).and_return false

    error = double("error")
    error.stub(:failure?).and_return false
    error.stub(:error?).and_return true

    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("example test")
    @suite.testcases << CI::Reporter::TestCase.new("failure test")
    @suite.testcases.last.failures << failure
    @suite.testcases << CI::Reporter::TestCase.new("error test")
    @suite.testcases.last.failures << error
    @suite.finish
    @suite.tests.should == 3
    @suite.failures.should == 1
    @suite.errors.should == 1
  end
end

describe "TestSuite xml" do
  before(:each) do
    ENV['CI_CAPTURE'] = nil
    @suite = CI::Reporter::TestSuite.new("example suite")
    @suite.assertions = 11
    begin
      raise StandardError, "an exception occurred"
    rescue => e
      @exception = e
    end
  end

  it "should render successfully with CI_CAPTURE off" do
    ENV['CI_CAPTURE'] = 'off'
    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("example test")
    @suite.finish
    xml = @suite.to_xml
  end

  it "should contain Ant/JUnit-formatted description of entire suite" do
    failure = double("failure")
    failure.stub(:failure?).and_return true
    failure.stub(:error?).and_return false
    failure.stub(:name).and_return "failure"
    failure.stub(:message).and_return "There was a failure"
    failure.stub(:location).and_return @exception.backtrace.join("\n")

    error = double("error")
    error.stub(:failure?).and_return false
    error.stub(:error?).and_return true
    error.stub(:name).and_return "error"
    error.stub(:message).and_return "There was a error"
    error.stub(:location).and_return @exception.backtrace.join("\n")

    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("example test")
    @suite.testcases << CI::Reporter::TestCase.new("skipped test").tap {|tc| tc.skipped = true }
    @suite.testcases << CI::Reporter::TestCase.new("failure test")
    @suite.testcases.last.failures << failure
    @suite.testcases << CI::Reporter::TestCase.new("error test")
    @suite.testcases.last.failures << error
    @suite.finish

    xml = @suite.to_xml
    doc = REXML::Document.new(xml)
    testsuite = doc.root.elements.to_a("/testsuite")
    testsuite.length.should == 1
    testsuite = testsuite.first
    testsuite.attributes["name"].should == "example suite"
    testsuite.attributes["assertions"].should == "11"
    testsuite.attributes["timestamp"].should match(/(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/)

    testcases = testsuite.elements.to_a("testcase")
    testcases.length.should == 4
  end

  it "should contain full exception type and message in location element" do
    failure = double("failure")
    failure.stub(:failure?).and_return true
    failure.stub(:error?).and_return false
    failure.stub(:name).and_return "failure"
    failure.stub(:message).and_return "There was a failure"
    failure.stub(:location).and_return @exception.backtrace.join("\n")

    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("example test")
    @suite.testcases << CI::Reporter::TestCase.new("failure test")
    @suite.testcases.last.failures << failure
    @suite.finish

    xml = @suite.to_xml
    doc = REXML::Document.new(xml)
    elem = doc.root.elements.to_a("/testsuite/testcase[@name='failure test']/failure").first
    location = elem.texts.join
    location.should =~ Regexp.new(failure.message)
    location.should =~ Regexp.new(failure.name)
  end

  it "should filter attributes properly for invalid characters" do
    failure = double("failure")
    failure.stub(:failure?).and_return true
    failure.stub(:error?).and_return false
    failure.stub(:name).and_return "failure"
    failure.stub(:message).and_return "There was a <failure>\nReason: blah"
    failure.stub(:location).and_return @exception.backtrace.join("\n")

    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("failure test")
    @suite.testcases.last.failures << failure
    @suite.finish

    xml = @suite.to_xml
    xml.should =~ %r/message="There was a &lt;failure&gt;\.\.\."/
  end
end

describe "A TestCase" do
  before(:each) do
    @tc = CI::Reporter::TestCase.new("example test")
  end

  it "should collect timings when start and finish are invoked in sequence" do
    @tc.start
    @tc.finish
    @tc.time.should >= 0
  end
end
