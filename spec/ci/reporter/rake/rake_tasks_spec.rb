# Copyright (c) 2006-2012 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

require File.dirname(__FILE__) + "/../../../spec_helper.rb"
require 'rake'

require 'ci/reporter/internal'
include CI::Reporter::Internal

THIS_SPEC_DIR = File.dirname(__FILE__)
['test-unit', 'rspec-core', 'cucumber'].each do |gem|
  load THIS_SPEC_DIR + "/rake_tasks_spec_#{gem}.rb"
end
