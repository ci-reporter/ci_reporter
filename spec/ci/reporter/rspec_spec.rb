# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"
require 'stringio'

context "The RSpec reporter" do
  setup do
    @error = mock("error")
    @error.stub!(:exception).and_return do
      begin
        raise StandardError, "error message"
      rescue => e
        e
      end
    end
    @error.stub!(:expectation_not_met?).and_return(false)
    @report_mgr = mock("report manager")
    @fmt = CI::Reporter::RSpec.new(StringIO.new(""), false, false, @report_mgr)
  end

  specify "should create a test suite with one success and one failure" do
    @report_mgr.should_receive(:write_report).and_return do |suite|
      suite.testcases.length.should == 2
      suite.testcases.first.should_not_be_failure
      suite.testcases.first.should_not_be_error
      suite.testcases.last.should_be_error
    end

    @fmt.start(2)
    @fmt.add_context("A context", true)
    @fmt.spec_started("should pass")
    @fmt.spec_passed("should pass")
    @fmt.spec_started("should fail")
    @fmt.spec_failed("should fail", 1, @error)
    @fmt.dump_summary(0.1, 2, 1)
  end
end