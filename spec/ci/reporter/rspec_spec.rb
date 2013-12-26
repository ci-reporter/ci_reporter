# Copyright (c) 2006-2013 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"
require 'stringio'

describe "The RSpec reporter" do
  before(:each) do
    @error = double("error")
    @error.stub(:expectation_not_met?).and_return(false)
    @error.stub(:pending_fixed?).and_return(false)
    @error.stub(:exception).and_return(StandardError.new)
    @report_mgr = double("report manager")
    @options = double("options")
    @args = [@options, StringIO.new("")]
    @args.shift unless defined?(::Spec) && ::Spec::VERSION::MAJOR == 1 && ::Spec::VERSION::MINOR >= 1
    @fmt = CI::Reporter::RSpec.new *@args
    @fmt.report_manager = @report_mgr
    @formatter = double("formatter")
    @fmt.formatter = @formatter
  end

  it "should use a progress bar formatter by default" do
    fmt = CI::Reporter::RSpec.new *@args
    fmt.formatter.should be_instance_of(CI::Reporter::RSpecFormatters::ProgressFormatter)
  end

  it "should use a specdoc formatter for RSpecDoc" do
    fmt = CI::Reporter::RSpecDoc.new *@args
    fmt.formatter.should be_instance_of(CI::Reporter::RSpecFormatters::DocFormatter)
  end

  it "should create a test suite with one success, one failure, and one pending" do
    @report_mgr.should_receive(:write_report).and_return do |suite|
      suite.testcases.length.should == 3
      suite.testcases[0].should_not be_failure
      suite.testcases[0].should_not be_error
      suite.testcases[1].should be_error
      suite.testcases[2].name.should =~ /\(PENDING\)/
    end

    example_group = double "example group"
    example_group.stub(:description).and_return "A context"

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
    @formatter.should_receive(:dump_failures).once
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
    @fmt.dump_failure(1, double("failure"))
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
    @formatter.should_receive(:dump_failures).once
    @report_mgr.should_receive(:write_report)

    @fmt.start(2)
    @fmt.add_behaviour("A context")
    @fmt.example_started("should pass")
    @fmt.example_passed("should pass")
    @fmt.dump_summary(0.1, 1, 0, 0)
  end

  it "should use the example #description method when available" do
    group = double "example group"
    group.stub(:description).and_return "group description"
    example = double "example"
    example.stub(:description).and_return "should do something"

    @formatter.should_receive(:start)
    @formatter.should_receive(:example_group_started).with(group)
    @formatter.should_receive(:example_started).with(example).once
    @formatter.should_receive(:example_passed).once
    @formatter.should_receive(:dump_summary)
    @formatter.should_receive(:dump_failures).once
    @report_mgr.should_receive(:write_report).and_return do |suite|
      suite.testcases.last.name.should == "should do something"
    end

    @fmt.start(2)
    @fmt.example_group_started(group)
    @fmt.example_started(example)
    @fmt.example_passed(example)
    @fmt.dump_summary(0.1, 1, 0, 0)
  end

  it "should create a test suite with failure in before(:all)" do
    example_group = double "example group"
    example_group.stub(:description).and_return "A context"

    @formatter.should_receive(:start)
    @formatter.should_receive(:example_group_started).with(example_group)
    @formatter.should_receive(:example_started).once
    @formatter.should_receive(:example_failed).once
    @formatter.should_receive(:dump_summary)
    @formatter.should_receive(:dump_failures).once
    @report_mgr.should_receive(:write_report)

    @fmt.start(2)
    @fmt.example_group_started(example_group)
    @fmt.example_failed("should fail", 1, @error)
    @fmt.dump_summary(0.1, 1, 0, 0)
  end

  describe 'RSpec2Failure' do
    before(:each) do
      @formatter = double "formatter"
      @formatter.should_receive(:format_backtrace).and_return("backtrace")
      @rspec20_example = double('RSpec2.0 Example',
                              :execution_result => {:exception_encountered => StandardError.new('rspec2.0 ftw')},
                              :metadata => {})
      @rspec22_example = double('RSpec2.2 Example',
                              :execution_result => {:exception => StandardError.new('rspec2.2 ftw')},
                              :metadata => {})
    end

    it 'should handle rspec (< 2.2) execution results' do
      failure = CI::Reporter::RSpec2Failure.new(@rspec20_example, @formatter)
      failure.name.should_not be_nil
      failure.message.should == 'rspec2.0 ftw'
      failure.location.should_not be_nil
    end
    it 'should handle rspec (>= 2.2) execution results' do
      failure = CI::Reporter::RSpec2Failure.new(@rspec22_example, @formatter)
      failure.name.should_not be_nil
      failure.message.should == 'rspec2.2 ftw'
      failure.location.should_not be_nil
    end
  end
end
