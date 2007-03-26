# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'rubygems'
gem 'rspec'
require 'spec'
$: << File.dirname(__FILE__) + "/../lib"
require 'ci/reporter/core'
require 'ci/reporter/test_unit'
require 'ci/reporter/rspec'

REPORTS_DIR = File.dirname(__FILE__) + "/reports"