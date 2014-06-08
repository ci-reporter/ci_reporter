# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

begin
  gem 'ci_reporter'
rescue Gem::LoadError
  $: << File.dirname(__FILE__) + "/../lib"
end
require 'ci/reporter/rake/test_unit'

namespace :ci do
  task :setup_testunit => "ci:setup:testunit"
end
