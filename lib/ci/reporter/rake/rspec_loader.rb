require 'rubygems'
begin
  gem 'ci_reporter'
rescue => e
  $: << File.dirname(__FILE__) + "/../../../lib"
end
require 'ci/reporter/rspec'