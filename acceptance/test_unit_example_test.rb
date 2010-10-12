require 'test/unit'

class TestUnitExampleTestOne < Test::Unit::TestCase
  def test_one
    puts "Some <![CDATA[on stdout]]>"
    assert(false, "First failure")
  end
  def teardown
    raise "second failure"
  end
end

class TestUnitExampleTestTwo < Test::Unit::TestCase
  def test_two
    assert true
  end
end
