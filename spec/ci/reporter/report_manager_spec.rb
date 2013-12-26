# Copyright (c) 2006-2013 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../spec_helper.rb"

describe "The ReportManager" do
  before(:each) do
    @reports_dir = REPORTS_DIR
    ENV.delete 'MAX_FILENAME_SIZE'
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
    suite = double("test suite")
    suite.should_receive(:name).and_return("some test suite name")
    suite.should_receive(:to_xml).and_return("<xml></xml>")
    reporter.write_report(suite)
    filename = "#{REPORTS_DIR}/SPEC-some-test-suite-name.xml"
    File.exist?(filename).should be_true
    File.open(filename) {|f| f.read.should == "<xml></xml>"}
  end

  it "should shorten extremely long report filenames" do
    reporter = CI::Reporter::ReportManager.new("spec")
    suite = double("test suite")
    very_long_name = "some test suite name that goes on and on and on and on and on and on and does not look like it will end any time soon and just when you think it is almost over it just continues to go on and on and on and on and on until it is almost over but wait there is more and then el fin"
    suite.should_receive(:name).and_return(very_long_name)
    suite.should_receive(:to_xml).and_return("<xml></xml>")
    reporter.write_report(suite)
    filename = "#{REPORTS_DIR}/SPEC-#{very_long_name}"[0..CI::Reporter::ReportManager::MAX_FILENAME_SIZE].gsub(/\s/, '-') + ".xml"
    filename.length.should be <= 255
    File.exist?(filename).should be_true
    File.open(filename) {|f| f.read.should == "<xml></xml>"}
  end

  it "should shorten extremely long report filenames to custom length" do
    reporter = CI::Reporter::ReportManager.new("spec")
    suite = double("test suite")
    very_long_name = "some test suite name that goes on and on and on and on and on and on and does not look like it will end any time soon and just when you think it is almost over it just continues to go on and on and on and on and on until it is almost over but wait there is more and then el fin"
    suite.should_receive(:name).and_return(very_long_name)
    suite.should_receive(:to_xml).and_return("<xml></xml>")
    ENV['MAX_FILENAME_SIZE'] = '170'
    reporter.write_report(suite)
    filename = "#{REPORTS_DIR}/SPEC-#{very_long_name}"[0..170].gsub(/\s/, '-') + ".xml"
    filename.length.should be <= 188
    File.exist?(filename).should be_true
    File.open(filename) {|f| f.read.should == "<xml></xml>"}
  end

  it "sidesteps existing files by adding an incrementing number" do
    filename = "#{REPORTS_DIR}/SPEC-colliding-test-suite-name.xml"
    FileUtils.mkdir_p(File.dirname(filename))
    FileUtils.touch filename
    reporter = CI::Reporter::ReportManager.new("spec")
    suite = double("test suite")
    suite.should_receive(:name).and_return("colliding test suite name")
    suite.should_receive(:to_xml).and_return("<xml></xml>")
    reporter.write_report(suite)
    File.exist?(filename.sub('.xml', '.0.xml')).should be_true
  end
end
