# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require 'rubygems'
begin
  gem 'ci_reporter'
rescue => e
  $: << File.dirname(__FILE__) + "/../../../lib"
end
require 'ci/reporter/rspec'