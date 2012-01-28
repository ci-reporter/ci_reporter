require 'minitest/autorun'

class MiniTestExampleTestOne < MiniTest::Unit::TestCase
  def test_one
    puts "Some <![CDATA[on stdout]]>"
    assert false
  end
  def teardown
    raise "second failure"
  end
end

class MiniTestExampleTestTwo < MiniTest::Unit::TestCase
  def test_two
    assert true
  end
end
