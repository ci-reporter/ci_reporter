require 'rubygems'
require_gem 'rspec'
require 'spec'
$: << File.dirname(__FILE__) + "/../lib"
require 'ci/reporter/core'
# require 'ci/reporter/test_unit'
require 'ci/reporter/rspec'

REPORTS_DIR = File.dirname(__FILE__) + "/reports"