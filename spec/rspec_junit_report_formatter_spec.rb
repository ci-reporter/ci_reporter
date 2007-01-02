require 'stringio'
require 'rexml/document'
require 'rubygems'
require_gem 'rspec'
require 'spec'
require File.dirname(__FILE__) + '/../lib/rspec_junit_report_formatter'

context "The JUnitReportFormatter" do
  setup do
    @reports_dir = File.dirname(__FILE__) + "/reports"

    @failure = mock("failure")
    @failure.stub!(:exception).and_return do
      begin
        raise StandardError, "failure message"
      rescue => e
        e
      end
    end
    @failure.stub!(:expectation_not_met?).and_return(false)

    @io = StringIO.new("")
    @fmt = RSpec::JUnitReportFormatter.new(@io)
  end

  teardown do
    FileUtils.rm_rf(@reports_dir)
  end

  specify "should create an XML file with one success and one failure" do
    @fmt.start(2)
    @fmt.add_context("A context", true)
    @fmt.spec_started("should pass")
    @fmt.spec_passed("should pass")
    @fmt.spec_started("should fail")
    @fmt.spec_failed("should fail", 1, @failure)
    @fmt.dump_summary(0.1, 2, 1)
    spec_file = Dir["#{@reports_dir}/*.xml"].to_a
    spec_file.length.should == 1
    spec_file = spec_file.first
    doc = File.open(spec_file) {|f| REXML::Document.new(f) }
    doc.root.elements.to_a("//testcase").length.should == 2
    doc.root.elements.to_a("//testcase/failure").length.should == 1
  end
end