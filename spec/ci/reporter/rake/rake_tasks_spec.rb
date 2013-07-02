# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../../spec_helper.rb"
require 'rake'

def save_env(v)
  ENV["PREV_#{v}"] = ENV[v]
end
def restore_env(v)
  ENV[v] = ENV["PREV_#{v}"]
  ENV.delete("PREV_#{v}")
end

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
