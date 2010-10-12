# Copyright (c) 2006-2010 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'rubygems'
begin
  require 'rspec'
rescue
  require 'spec'
end

unless defined?(CI_REPORTER_LIB)
  CI_REPORTER_LIB = File.expand_path(File.dirname(__FILE__) + "/../lib")
  $: << CI_REPORTER_LIB
end

require 'ci/reporter/core'
require 'ci/reporter/test_unit'
require 'ci/reporter/rspec'

REPORTS_DIR = File.dirname(__FILE__) + "/reports" unless defined?(REPORTS_DIR)
