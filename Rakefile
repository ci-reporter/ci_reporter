#--
# Copyright (c) 2006-2014 Nick Sieger <nicksieger@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.
#++

require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = FileList['spec']
  t.rspec_opts = "--color"
end

task :default => :rspec
