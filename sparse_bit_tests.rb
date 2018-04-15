require 'minitest/autorun'
require_relative './sparse_bit'

class TestSparseBit < MiniTest::Unit::TestCase
  def setup
    @b=SparseBit.new(1000)
  end

  def test_set_get_true
    (1..1000).each do |i|
      @b.set(i,true)
      assert_equal true,@b.get(i)
    end
  end

  def test_set_get_false
    (1..1000).each do |i|
      @b.set(i,false)
      assert_equal false,@b.get(i)
    end
  end
end
