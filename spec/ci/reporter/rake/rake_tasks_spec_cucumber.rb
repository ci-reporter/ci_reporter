describe "ci_reporter ci:setup:cucumber task" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    load CI_REPORTER_LIB + '/ci/reporter/rake/cucumber.rb'
    save_env "CI_REPORTS"
    save_env "CUCUMBER_OPTS"
    ENV["CI_REPORTS"] = "some-bogus-nonexistent-directory-that-wont-fail-rm_rf"
  end
  after(:each) do
    restore_env "CUCUMBER_OPTS"
    restore_env "CI_REPORTS"
    Rake.application = nil
  end

  it "should set ENV['CUCUMBER_OPTS'] to include cucumber formatter args" do
    @rake["ci:setup:cucumber"].invoke
    ENV["CUCUMBER_OPTS"].should =~ /--format\s+CI::Reporter::Cucumber/
  end

  it "should not set ENV['CUCUMBER_OPTS'] to require cucumber_loader" do
    @rake["ci:setup:cucumber"].invoke
    ENV["CUCUMBER_OPTS"].should_not =~ /.*--require\s+\S*cucumber_loader.*/
  end

  it "should append to ENV['CUCUMBER_OPTS'] if it already contains a value" do
    ENV["CUCUMBER_OPTS"] = "somevalue".freeze
    @rake["ci:setup:cucumber"].invoke
    ENV["CUCUMBER_OPTS"].should =~ /somevalue.*\s--format\s+CI::Reporter::Cucumber/
  end
end
