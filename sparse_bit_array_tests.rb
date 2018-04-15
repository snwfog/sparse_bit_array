require 'minitest/autorun'
require_relative './sparse_bit_array'

class TestSparseBit < MiniTest::Unit::TestCase
  def setup
    @b = SparseBitArray.new(1000)
  end

  def test_set_get_bit
    (0...1_000).each { |i| @b.set(i); assert_equal true, @b.get(i) }
  end

  def test_clear_get_bit
    (0...1_000).each { |i| @b.clear(i); assert_equal false, @b.get(i) }
  end

  def test_index_out_of_bound
    assert_raises(SparseBitArray::IndexOutOfBound) { @b.set(1000) }
    assert_raises(SparseBitArray::IndexOutOfBound) { @b.set(-1) }
  end

  def test_stats
    bit_array    = SparseBitArray.new(1 << 13)
    bit_array[0] = true # 1 level 3 block
    assert_equal Hash[block1_size: 1, block2_size: 1, block3_size: 1], bit_array.stats

    bit_array[1] = true # 1 level 3 block
    assert_equal Hash[block1_size: 1, block2_size: 1, block3_size: 1], bit_array.stats

    bit_array[64] = true # 2 level 3 block
    assert_equal Hash[block1_size: 1, block2_size: 1, block3_size: 2], bit_array.stats

    bit_array[2048] = true # 1 level 2 block
    assert_equal Hash[block1_size: 1, block2_size: 2, block3_size: 3], bit_array.stats

    bit_array[2048] = false
    assert_equal Hash[block1_size: 1, block2_size: 2, block3_size: 2], bit_array.stats

    bit_array[64] = false
    assert_equal Hash[block1_size: 1, block2_size: 2, block3_size: 1], bit_array.stats

    bit_array[1] = false
    assert_equal Hash[block1_size: 1, block2_size: 2, block3_size: 1], bit_array.stats

    bit_array[0] = false
    assert_equal Hash[block1_size: 1, block2_size: 2, block3_size: 0], bit_array.stats
  end

  def test_attr_accessor_shortcuts # [], []=
    (0...1_000).each { |i| @b[i] = true; assert_equal(true, @b[i]) }
    (0...1_000).each { |i| @b[i] = false; assert_equal(false, @b[i]) }
  end
end
