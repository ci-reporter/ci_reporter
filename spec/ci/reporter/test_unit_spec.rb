# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"

describe "The TestUnit reporter" do
  before(:each) do
    @report_mgr = mock("report manager")
    @testunit = CI::Reporter::TestUnit.new(nil, @report_mgr)
    @result = mock("result")
    @result.stub!(:assertion_count).and_return(7)
  end

  it "should build suites based on adjacent tests with the same class name" do
    @suite = nil
    @report_mgr.should_receive(:write_report).once.and_return {|suite| @suite = suite }

    @testunit.started(@result)
    @testunit.test_started("test_one(TestCaseClass)")
    @testunit.test_finished("test_one(TestCaseClass)")
    @testunit.test_started("test_two(TestCaseClass)")
    @testunit.test_finished("test_two(TestCaseClass)")
    @testunit.finished(10)

    @suite.name.should == "TestCaseClass"
    @suite.testcases.length.should == 2
    @suite.testcases.first.name.should == "test_one"
    @suite.testcases.first.should_not be_failure
    @suite.testcases.first.should_not be_error
    @suite.testcases.last.name.should == "test_two"
    @suite.testcases.last.should_not be_failure
    @suite.testcases.last.should_not be_error
  end
  
  it "should build two suites when encountering different class names" do
    @suites = []
    @report_mgr.should_receive(:write_report).twice.and_return {|suite| @suites << suite }

    @testunit.started(@result)
    @testunit.test_started("test_one(TestCaseClass)")
    @testunit.test_finished("test_one(TestCaseClass)")
    @testunit.test_started("test_two(AnotherTestCaseClass)")
    @testunit.test_finished("test_two(AnotherTestCaseClass)")
    @testunit.finished(10)

    @suites.first.name.should == "TestCaseClass"
    @suites.first.testcases.length.should == 1
    @suites.first.testcases.first.name.should == "test_one"
    @suites.last.name.should == "AnotherTestCaseClass"
    @suites.last.testcases.length.should == 1
    @suites.last.testcases.first.name.should == "test_two"
  end
  
  it "should record assertion counts during test run" do
    @suite = nil
    @report_mgr.should_receive(:write_report).and_return {|suite| @suite = suite }

    @testunit.started(@result)
    @testunit.test_started("test_one(TestCaseClass)")
    @testunit.test_finished("test_one(TestCaseClass)")
    @testunit.finished(10)

    @suite.assertions.should == 7
  end
  
  it "should add failures to testcases when encountering a fault" do
    begin
      raise StandardError, "error"
    rescue => e
      @error = Test::Unit::Error.new("test_two(TestCaseClass)", e)
    end

    @suite = nil
    @report_mgr.should_receive(:write_report).once.and_return {|suite| @suite = suite }

    @testunit.started(@result)
    @testunit.test_started("test_one(TestCaseClass)")
    @testunit.test_finished("test_one(TestCaseClass)")
    @testunit.test_started("test_two(TestCaseClass)")
    @testunit.fault(@error)
    @testunit.finished(10)

    @suite.name.should == "TestCaseClass"
    @suite.testcases.length.should == 2
    @suite.testcases.first.name.should == "test_one"
    @suite.testcases.first.should_not be_failure
    @suite.testcases.first.should_not be_error
    @suite.testcases.last.name.should == "test_two"
    @suite.testcases.last.should_not be_failure
    @suite.testcases.last.should be_error
  end
end