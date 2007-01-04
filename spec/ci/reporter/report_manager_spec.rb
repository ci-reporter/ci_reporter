require File.dirname(__FILE__) + "/../../spec_helper.rb"

context "The ReportManager" do
  setup do
    @reports_dir = REPORTS_DIR
  end

  teardown do
    FileUtils.rm_rf @reports_dir
    ENV["CI_REPORTS"] = nil
  end

  specify "should create the report directory according to the given prefix" do
    CI::Reporter::ReportManager.new("spec")
    File.directory?(@reports_dir).should_be true
  end
  
  specify "should create the report directory based on CI_REPORTS environment variable if set" do
    @reports_dir = "#{Dir.getwd}/dummy"
    ENV["CI_REPORTS"] = @reports_dir
    CI::Reporter::ReportManager.new("spec")
    File.directory?(@reports_dir).should_be true
  end
  
  specify "should write reports based on name and xml content of a test suite" do
    reporter = CI::Reporter::ReportManager.new("spec")
    suite = mock("test suite")
    suite.should_receive(:name).and_return("some test suite name")
    suite.should_receive(:to_xml).and_return("<xml></xml>")
    reporter.write_report(suite)
    filename = "#{REPORTS_DIR}/SPEC-some-test-suite-name.xml"
    File.exist?(filename).should_be true
    File.open(filename) {|f| f.read.should == "<xml></xml>"}
  end
end