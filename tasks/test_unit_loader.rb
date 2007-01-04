$: << File.dirname(__FILE__) + "/../lib"
require 'ci/reporter/test_unit'

class Test::Unit::UI::Console::TestRunner
  def create_mediator(suite)  # swap in our custom mediator
    return CI::Reporter::TestUnit.new(suite)
  end
end