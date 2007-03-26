# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

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
