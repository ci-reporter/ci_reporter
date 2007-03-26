# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"
require 'rexml/document'

context "A TestSuite" do
  setup do
    @suite = CI::Reporter::TestSuite.new("example suite")
  end

  specify "should collect timings when start and finish are invoked in sequence" do
    @suite.start
    @suite.finish
    @suite.time.should_be > 0
  end
  
  specify "should aggregate tests" do
    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("example test")
    @suite.finish
    @suite.tests.should == 1
  end
  
  specify "should indicate number of failures and errors" do
    failure = mock("failure")
    failure.stub!(:failure?).and_return true
    failure.stub!(:error?).and_return false

    error = mock("error")
    error.stub!(:failure?).and_return false
    error.stub!(:error?).and_return true

    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("example test")
    @suite.testcases << CI::Reporter::TestCase.new("failure test")
    @suite.testcases.last.failure = failure
    @suite.testcases << CI::Reporter::TestCase.new("error test")
    @suite.testcases.last.failure = error
    @suite.finish
    @suite.tests.should == 3
    @suite.failures.should == 1
    @suite.errors.should == 1
  end
  
end

context "TestSuite xml" do
  setup do
    @suite = CI::Reporter::TestSuite.new("example suite")
    @suite.assertions = 11
    begin
      raise StandardError, "an exception occurred"
    rescue => e
      @exception = e
    end
  end

  specify "should contain Ant/JUnit-formatted description of entire suite" do
    failure = mock("failure")
    failure.stub!(:failure?).and_return true
    failure.stub!(:error?).and_return false
    failure.stub!(:name).and_return "failure"
    failure.stub!(:message).and_return "There was a failure"
    failure.stub!(:location).and_return @exception.backtrace.join("\n")

    error = mock("error")
    error.stub!(:failure?).and_return false
    error.stub!(:error?).and_return true
    error.stub!(:name).and_return "error"
    error.stub!(:message).and_return "There was a error"
    error.stub!(:location).and_return @exception.backtrace.join("\n")

    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("example test")
    @suite.testcases << CI::Reporter::TestCase.new("failure test")
    @suite.testcases.last.failure = failure
    @suite.testcases << CI::Reporter::TestCase.new("error test")
    @suite.testcases.last.failure = error
    @suite.finish

    xml = @suite.to_xml
    doc = REXML::Document.new(xml)
    testsuite = doc.root.elements.to_a("/testsuite")
    testsuite.length.should == 1
    testsuite = testsuite.first
    testsuite.attributes["name"].should == "example suite"
    testsuite.attributes["assertions"].should == "11"

    testcases = testsuite.elements.to_a("testcase")
    testcases.length.should == 3
  end
  
  specify "should filter attributes properly for invalid characters" do
    failure = mock("failure")
    failure.stub!(:failure?).and_return true
    failure.stub!(:error?).and_return false
    failure.stub!(:name).and_return "failure"
    failure.stub!(:message).and_return "There was a <failure>\nReason: blah"
    failure.stub!(:location).and_return @exception.backtrace.join("\n")

    @suite.start
    @suite.testcases << CI::Reporter::TestCase.new("failure test")
    @suite.testcases.last.failure = failure
    @suite.finish

    xml = @suite.to_xml
    xml.should_match %r/message="There was a &lt;failure&gt;\.\.\."/
  end
end

context "A TestCase" do
  setup do
    @tc = CI::Reporter::TestCase.new("example test")
  end

  specify "should collect timings when start and finish are invoked in sequence" do
    @tc.start
    @tc.finish
    @tc.time.should_be > 0
  end
end