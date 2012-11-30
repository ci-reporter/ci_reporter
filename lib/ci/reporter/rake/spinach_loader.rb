$: << File.dirname(__FILE__) + "/../../.."
require 'ci/reporter/spinach'

ENV['CI_CAPTURE'] = 'off'
CI::Reporter::Spinach.new.bind
