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

  describe CI::Reporter::Cucumber do
    before(:each) do
      @step_mother = mock("step_mother")
      @io = mock("io")

      @report_manager = mock("report_manager")
      CI::Reporter::ReportManager.stub!(:new).and_return(@report_manager)
    end

    def new_instance
      CI::Reporter::Cucumber.new(@step_mother, @io, {})
    end

    it "should create a new report manager to report on test success/failure" do
      CI::Reporter::ReportManager.should_receive(:new)
      new_instance
    end

    it "should record the feature name when a new feature is visited" do
      cucumber = new_instance
      cucumber.visit_feature_name("Some feature name")
      cucumber.feature_name.should == "Some feature name"
    end

    it "should record only the first line of a feature name" do
      cucumber = new_instance
      cucumber.visit_feature_name("Some feature name\nLonger description")
      cucumber.feature_name.should == "Some feature name"
    end

    describe "when visiting a new scenario" do
      before(:each) do
        @cucumber = new_instance
        @cucumber.visit_feature_name("Demo feature")

        @test_suite = mock("test_suite", :start => nil, :finish => nil)
        CI::Reporter::TestSuite.stub!(:new).and_return(@test_suite)

        @feature_element = mock("feature_element", :accept => true)

        @report_manager.stub!(:write_report)
      end

      it "should create a new test suite" do
        # FIXME: @name is feature_element purely as a by-product of the
        # mocking framework implementation.  But then again, using
        # +instance_variable_get+ in the first place is a bit icky.
        CI::Reporter::TestSuite.should_receive(:new).with("Demo feature feature_element")
        @cucumber.visit_feature_element(@feature_element)
      end

      it "should indicate that the test suite has started" do
        @test_suite.should_receive(:start)
        @cucumber.visit_feature_element(@feature_element)
      end

      it "should indicate that the test suite has finished" do
        @test_suite.should_receive(:finish)
        @cucumber.visit_feature_element(@feature_element)
      end

      it "should ask the report manager to write a report" do
        @report_manager.should_receive(:write_report).with(@test_suite)
        @cucumber.visit_feature_element(@feature_element)
      end
    end

    describe "when visiting a step inside a scenario" do
      before(:each) do
        @testcases = []

        @test_suite = mock("test_suite", :testcases => @testcases)

        @cucumber = new_instance
        @cucumber.stub!(:test_suite).and_return(@test_suite)

        @test_case = mock("test_case", :start => nil, :finish => nil, :name => "Step Name")
        CI::Reporter::TestCase.stub!(:new).and_return(@test_case)

        @step = mock("step", :accept => true, :status => :passed)
        @step.stub!(:name).and_return("Step Name")
      end

      it "should create a new test case" do
        CI::Reporter::TestCase.should_receive(:new).with("Step Name")
        @cucumber.visit_step(@step)
      end

      it "should indicate that the test case has started" do
        @test_case.should_receive(:start)
        @cucumber.visit_step(@step)
      end

      it "should indicate that the test case has finished" do
        @test_case.should_receive(:finish)
        @cucumber.visit_step(@step)
      end

      it "should add the test case to the suite's list of cases" do
        @testcases.should be_empty
        @cucumber.visit_step(@step)
        @testcases.should_not be_empty
        @testcases.first.should == @test_case
      end

      it "should alter the name of a test case that is pending to include '(PENDING)'" do
        @step.stub!(:status).and_return(:pending)
        @test_case.should_receive(:name=).with("Step Name (PENDING)")
        @cucumber.visit_step(@step)
      end

      it "should alter the name of a test case that is undefined to include '(PENDING)'" do
        @step.stub!(:status).and_return(:undefined)
        @test_case.should_receive(:name=).with("Step Name (PENDING)")
        @cucumber.visit_step(@step)
      end

      it "should alter the name of a test case that was skipped to include '(SKIPPED)'" do
        @step.stub!(:status).and_return(:skipped)
        @test_case.should_receive(:name=).with("Step Name (SKIPPED)")
        @cucumber.visit_step(@step)
      end

      describe "that fails" do
        before(:each) do
          @step.stub!(:status).and_return(:failed)

          @failures = []
          @test_case.stub!(:failures).and_return(@failures)

          @cucumber_failure = mock("cucumber_failure")
          CI::Reporter::CucumberFailure.stub!(:new).and_return(@cucumber_failure)
        end

        it "should create a new cucumber failure with that step" do
          CI::Reporter::CucumberFailure.should_receive(:new).with(@step)
          @cucumber.visit_step(@step)
        end

        it "should add the failure to the suite's list of failures" do
          @failures.should be_empty
          @cucumber.visit_step(@step)
          @failures.should_not be_empty
          @failures.first.should == @cucumber_failure
        end
      end
    end
  end
end
