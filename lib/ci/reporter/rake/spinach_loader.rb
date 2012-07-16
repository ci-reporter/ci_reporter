$: << File.dirname(__FILE__) + "/../../.."
require 'ci/reporter/spinach'

CI::Reporter::Spinach.new.bind
