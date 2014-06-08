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

THIS_SPEC_DIR = File.dirname(__FILE__)
['rspec-core', 'cucumber'].each do |gem|
  load THIS_SPEC_DIR + "/rake_tasks_spec_#{gem}.rb"
end
