begin
  gem 'ci_reporter'
rescue
  $: << File.dirname(__FILE__) + "/../lib"
end
require 'ci/reporter/rake/rspec'
require 'ci/reporter/rake/test_unit'

namespace :ci do
  task :setup_rspec => "ci:setup:rspec"
  task :setup_testunit => "ci:setup:testunit"
end
