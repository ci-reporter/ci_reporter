describe "ci_reporter ci:setup:testunit task" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    load CI_REPORTER_LIB + '/ci/reporter/rake/test_unit.rb'
    save_env "CI_REPORTS"
    save_env "TESTOPTS"
    ENV["CI_REPORTS"] = "some-bogus-nonexistent-directory-that-wont-fail-rm_rf"
  end
  after(:each) do
    restore_env "TESTOPTS"
    restore_env "CI_REPORTS"
    Rake.application = nil
  end

  it "should set ENV['TESTOPTS'] to include test/unit setup file" do
    @rake["ci:setup:testunit"].invoke
    ENV["TESTOPTS"].should =~ /test_unit_loader/
  end

  it "should append to ENV['TESTOPTS'] if it already contains a value" do
    ENV["TESTOPTS"] = "somevalue".freeze
    @rake["ci:setup:testunit"].invoke
    ENV["TESTOPTS"].should =~ /somevalue.*test_unit_loader/
  end
end
