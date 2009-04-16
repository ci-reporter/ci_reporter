# (c) Copyright 2006-2008 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"
require 'stringio'

describe "The RSpec reporter" do
  before(:each) do
    @error = mock("error")
    @error.stub!(:expectation_not_met?).and_return(false)
    @error.stub!(:pending_fixed?).and_return(false)
    @report_mgr = mock("report manager")
    @options = mock("options")
    @args = [@options, StringIO.new("")]
    @args.shift if Spec::VERSION::MAJOR == 1 && Spec::VERSION::MINOR < 1
    @fmt = CI::Reporter::RSpec.new *@args
    @fmt.report_manager = @report_mgr
    @formatter = mock("formatter")
    @fmt.formatter = @formatter
  end

  it "should use a progress bar formatter by default" do
    fmt = CI::Reporter::RSpec.new *@args
    fmt.formatter.should be_instance_of(Spec::Runner::Formatter::ProgressBarFormatter)
  end

  it "should use a specdoc formatter for RSpecDoc" do
    fmt = CI::Reporter::RSpecDoc.new *@args
    fmt.formatter.should be_instance_of(Spec::Runner::Formatter::SpecdocFormatter)
  end

  it "should create a test suite with one success, one failure, and one pending" do
    @report_mgr.should_receive(:write_report).and_return do |suite|
      suite.testcases.length.should == 3
      suite.testcases[0].should_not be_failure
      suite.testcases[0].should_not be_error
      suite.testcases[1].should be_error
      suite.testcases[2].name.should =~ /\(PENDING\)/
    end

    example_group = mock "example group"
    example_group.stub!(:description).and_return "A context"

    @formatter.should_receive(:start).with(3)
    @formatter.should_receive(:example_group_started).with(example_group)
    @formatter.should_receive(:example_started).exactly(3).times
    @formatter.should_receive(:example_passed).once
    @formatter.should_receive(:example_failed).once
    @formatter.should_receive(:example_pending).once
    @formatter.should_receive(:start_dump).once
    @formatter.should_receive(:dump_failure).once
    @formatter.should_receive(:dump_summary).once
    @formatter.should_receive(:dump_pending).once
    @formatter.should_receive(:close).once

    @fmt.start(3)
    @fmt.example_group_started(example_group)
    @fmt.example_started("should pass")
    @fmt.example_passed("should pass")
    @fmt.example_started("should fail")
    @fmt.example_failed("should fail", 1, @error)
    @fmt.example_started("should be pending")
    @fmt.example_pending("A context", "should be pending", "Not Yet Implemented")
    @fmt.start_dump
    @fmt.dump_failure(1, mock("failure"))
    @fmt.dump_summary(0.1, 3, 1, 1)
    @fmt.dump_pending
    @fmt.close
  end

  it "should support RSpec 1.0.8 #add_behavior" do
    @formatter.should_receive(:start)
    @formatter.should_receive(:add_behaviour).with("A context")
    @formatter.should_receive(:example_started).once
    @formatter.should_receive(:example_passed).once
    @formatter.should_receive(:dump_summary)
    @report_mgr.should_receive(:write_report)

    @fmt.start(2)
    @fmt.add_behaviour("A context")
    @fmt.example_started("should pass")
    @fmt.example_passed("should pass")
    @fmt.dump_summary(0.1, 1, 0, 0)
  end

  it "should use the example #description method when available" do
    group = mock "example group"
    group.stub!(:description).and_return "group description"
    example = mock "example"
    example.stub!(:description).and_return "should do something"

    @formatter.should_receive(:start)
    @formatter.should_receive(:example_group_started).with(group)
    @formatter.should_receive(:example_started).with(example).once
    @formatter.should_receive(:example_passed).once
    @formatter.should_receive(:dump_summary)
    @report_mgr.should_receive(:write_report).and_return do |suite|
      suite.testcases.last.name.should == "should do something"
    end

    @fmt.start(2)
    @fmt.example_group_started(group)
    @fmt.example_started(example)
    @fmt.example_passed(example)
    @fmt.dump_summary(0.1, 1, 0, 0)
  end
end
