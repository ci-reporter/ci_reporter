# Copyright (c) 2006-2013 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"
require 'ci/reporter/cucumber'

describe "The Cucumber reporter" do
  describe CI::Reporter::CucumberFailure do
    before(:each) do
      @klass = double("class")
      @klass.stub(:name).and_return("Exception name")

      @exception = double("exception")
      @exception.stub(:class).and_return(@klass)
      @exception.stub(:message).and_return("Exception message")
      @exception.stub(:backtrace).and_return(["First line", "Second line"])

      @step = double("step")
      @step.stub(:exception).and_return(@exception)

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
      @step_mother = double("step_mother")
      @io = double("io")

      @report_manager = double("report_manager")
      CI::Reporter::ReportManager.stub(:new).and_return(@report_manager)
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
      cucumber.feature_name(nil, "Some feature name")
      cucumber.name.should == "Some feature name"
    end

    it "should record only the first line of a feature name" do
      cucumber = new_instance
      cucumber.feature_name(nil, "Some feature name\nLonger description")
      cucumber.name.should == "Some feature name"
    end

    context "applied to a feature" do
      before(:each) do
        @cucumber = new_instance
        @cucumber.feature_name(nil, "Demo feature")

        @test_suite = double("test_suite", :start => nil, :finish => nil, :name= => nil)
        CI::Reporter::TestSuite.stub(:new).and_return(@test_suite)

        @feature = double("feature")

        @report_manager.stub(:write_report)
      end

      context "before" do
        it "should create a new test suite" do
          CI::Reporter::TestSuite.should_receive(:new).with(/Demo feature/)
          @cucumber.before_feature(@feature)
        end

        it "should indicate that the test suite has started" do
          @test_suite.should_receive(:start)
          @cucumber.before_feature(@feature)
        end
      end

      context "after" do
        before :each do
          @cucumber = new_instance
          @cucumber.feature_name(nil, "Demo feature")

          @test_suite = double("test_suite", :start => nil, :finish => nil, :name= => nil)
          CI::Reporter::TestSuite.stub(:new).and_return(@test_suite)

          @feature = double("feature")

          @report_manager.stub(:write_report)

          @cucumber.before_feature(@feature)
        end

        it "should indicate that the test suite has finished" do
          @test_suite.should_receive(:finish)
          @cucumber.after_feature(@feature)
        end

        it "should ask the report manager to write a report" do
          @report_manager.should_receive(:write_report).with(@test_suite)
          @cucumber.after_feature(@feature)
        end
      end
    end

    context "inside a scenario" do
      before(:each) do
        @testcases = []

        @test_suite = double("test_suite", :testcases => @testcases)

        @cucumber = new_instance
        @cucumber.stub(:test_suite).and_return(@test_suite)

        @test_case = double("test_case", :start => nil, :finish => nil, :name => "Step Name")
        CI::Reporter::TestCase.stub(:new).and_return(@test_case)

        @step = double("step", :status => :passed)
        @step.stub(:name).and_return("Step Name")
      end

      context "before steps" do
        it "should create a new test case" do
          CI::Reporter::TestCase.should_receive(:new).with("Step Name")
          @cucumber.scenario_name(nil, "Step Name")
          @cucumber.before_steps(@step)
        end

        it "should indicate that the test case has started" do
          @test_case.should_receive(:start)
          @cucumber.before_steps(@step)
        end
      end

      context "after steps" do
        before :each do
          @cucumber.before_steps(@step)
        end

        it "should indicate that the test case has finished" do
          @test_case.should_receive(:finish)
          @cucumber.after_steps(@step)
        end

        it "should add the test case to the suite's list of cases" do
          @testcases.should be_empty
          @cucumber.after_steps(@step)
          @testcases.should_not be_empty
          @testcases.first.should == @test_case
        end

        it "should alter the name of a test case that is pending to include '(PENDING)'" do
          @step.stub(:status).and_return(:pending)
          @test_case.should_receive(:name=).with("Step Name (PENDING)")
          @cucumber.after_steps(@step)
        end

        it "should alter the name of a test case that is undefined to include '(PENDING)'" do
          @step.stub(:status).and_return(:undefined)
          @test_case.should_receive(:name=).with("Step Name (PENDING)")
          @cucumber.after_steps(@step)
        end

        it "should alter the name of a test case that was skipped to include '(SKIPPED)'" do
          @step.stub(:status).and_return(:skipped)
          @test_case.should_receive(:name=).with("Step Name (SKIPPED)")
          @cucumber.after_steps(@step)
        end
      end

      describe "that fails" do
        before(:each) do
          @step.stub(:status).and_return(:failed)

          @failures = []
          @test_case.stub(:failures).and_return(@failures)

          @cucumber.before_steps(@step)

          @cucumber_failure = double("cucumber_failure")
          CI::Reporter::CucumberFailure.stub(:new).and_return(@cucumber_failure)
        end

        it "should create a new cucumber failure with that step" do
          CI::Reporter::CucumberFailure.should_receive(:new).with(@step)
          @cucumber.after_steps(@step)
        end

        it "should add the failure to the suite's list of failures" do
          @failures.should be_empty
          @cucumber.after_steps(@step)
          @failures.should_not be_empty
          @failures.first.should == @cucumber_failure
        end
      end
    end
  end
end
