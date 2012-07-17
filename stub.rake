# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.
#
# Use this stub rakefile as a wrapper around a regular Rakefile.  Run in the
# same directory as the real Rakefile.
#
#   rake -f /path/to/ci_reporter/lib/ci/reporter/rake/stub.rake ci:setup:rspec default
#

load File.dirname(__FILE__) + '/lib/ci/reporter/rake/rspec.rb'
load File.dirname(__FILE__) + '/lib/ci/reporter/rake/cucumber.rb'
load File.dirname(__FILE__) + '/lib/ci/reporter/rake/test_unit.rb'
load File.dirname(__FILE__) + '/lib/ci/reporter/rake/minitest.rb'
load File.dirname(__FILE__) + '/lib/ci/reporter/rake/spinach.rb'
load 'Rakefile'
