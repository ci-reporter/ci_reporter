describe "ci_reporter ci:setup:rspec task" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    load CI_REPORTER_LIB + '/ci/reporter/rake/rspec.rb'
    save_env "CI_REPORTS"
    save_env "SPEC_OPTS"
    ENV["CI_REPORTS"] = "some-bogus-nonexistent-directory-that-wont-fail-rm_rf"
  end
  after(:each) do
    restore_env "SPEC_OPTS"
    restore_env "CI_REPORTS"
    Rake.application = nil
  end

  it "should set ENV['SPEC_OPTS'] to include rspec formatter args" do
    @rake["ci:setup:rspec"].invoke
    ENV["SPEC_OPTS"].should =~ /--require.*rspec_loader.*--format.*CI::Reporter::RSpec/
  end

  it "should set ENV['SPEC_OPTS'] to include rspec doc formatter if task is ci:setup:rspecdoc" do
    @rake["ci:setup:rspecdoc"].invoke
    ENV["SPEC_OPTS"].should =~ /--require.*rspec_loader.*--format.*CI::Reporter::RSpecDoc/
  end

  it "should set ENV['SPEC_OPTS'] to include rspec base formatter if task is ci:setup:rspecbase" do
    @rake["ci:setup:rspecbase"].invoke
    ENV["SPEC_OPTS"].should =~ /--require.*rspec_loader.*--format.*CI::Reporter::RSpecBase/
  end

  it "should append to ENV['SPEC_OPTS'] if it already contains a value" do
    ENV["SPEC_OPTS"] = "somevalue".freeze
    @rake["ci:setup:rspec"].invoke
    ENV["SPEC_OPTS"].should =~ /somevalue.*--require.*rspec_loader.*--format.*CI::Reporter::RSpec/
  end
end
