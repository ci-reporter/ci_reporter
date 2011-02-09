# Copyright (c) 2006-2010 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"

describe "The ReportManager" do
  before(:each) do
    @reports_dir = REPORTS_DIR
  end

  after(:each) do
    FileUtils.rm_rf @reports_dir
    ENV["CI_REPORTS"] = nil
  end

  it "should create the report directory according to the given prefix" do
    CI::Reporter::ReportManager.new("spec")
    File.directory?(@reports_dir).should be_true
  end
  
  it "should create the report directory based on CI_REPORTS environment variable if set" do
    @reports_dir = "#{Dir.getwd}/dummy"
    ENV["CI_REPORTS"] = @reports_dir
    CI::Reporter::ReportManager.new("spec")
    File.directory?(@reports_dir).should be_true
  end
  
  it "should write reports based on name and xml content of a test suite" do
    reporter = CI::Reporter::ReportManager.new("spec")
    suite = mock("test suite")
    suite.should_receive(:name).and_return("some test suite name")
    suite.should_receive(:to_xml).and_return("<xml></xml>")
    reporter.write_report(suite)
    filename = "#{REPORTS_DIR}/SPEC-some-test-suite-name.xml"
    File.exist?(filename).should be_true
    File.open(filename) {|f| f.read.should == "<xml></xml>"}
  end

  it "should not write files with names longer than 255 characters" do
    reporter = CI::Reporter::ReportManager.new("spec")
    suite = mock("test suite")
    suite.should_receive(:name).and_return("some " + ("long " * 50) + " suite name")
    suite.should_receive(:to_xml).and_return("<xml></xml>")
    reporter.write_report(suite)

    files = Dir["#{REPORTS_DIR}/SPEC-some-long-long-long-long*.xml"]
    files.size.should == 1
    files.first.split('/').last.size.should <= 255
  end
end
