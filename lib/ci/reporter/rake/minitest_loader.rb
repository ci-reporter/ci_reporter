# Copyright (c) 2012 Alexander Shcherbinin <alexander.shcherbinin@gmail.com>
# See the file LICENSE.txt included with the distribution for
# software license details.

$: << File.dirname(__FILE__) + "/../../.."
require 'ci/reporter/minitest'

# set defaults
MiniTest::Unit.runner = CI::Reporter::Runner.new
