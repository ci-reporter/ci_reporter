# Copyright (c) 2006-2013 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'rubygems'
begin
  require 'rspec'
rescue LoadError
  require 'spec'
end

require 'rspec/autorun' if $0 =~ /rcov$/

unless defined?(CI_REPORTER_LIB)
  CI_REPORTER_LIB = File.expand_path(File.dirname(__FILE__) + "/../lib")
  $: << CI_REPORTER_LIB
end

require 'ci/reporter/core'
require 'ci/reporter/test_unit'
require 'ci/reporter/rspec'

Test::Unit.run = true
REPORTS_DIR = File.dirname(__FILE__) + "/reports" unless defined?(REPORTS_DIR)
