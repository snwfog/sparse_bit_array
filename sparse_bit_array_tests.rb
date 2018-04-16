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

  def test_flip_get_bit
    (0...1_000).each do |i|
      @b.flip(i)
      assert_equal true, @b[i]
      @b.flip(i)
      assert_equal false, @b[i]
    end
  end

  def test_index_out_of_bound
    assert_raises(SparseBitArray::IndexOutOfBound) { @b.set(1000) }
    assert_raises(SparseBitArray::IndexOutOfBound) { @b.set(-1) }
  end

  def test_each
    bit_array               = SparseBitArray.new(1 << 17)
    bit_array[0], blk_count = true, 0
    bit_array.each { blk_count += 1 }
    assert_equal 1, blk_count

    bit_array[1 << 11], blk_count = true, 0
    bit_array[2 * (1 << 11)]      = true
    bit_array[3 * (1 << 11)]      = true
    bit_array[4 * (1 << 11)]      = true
    bit_array.each { blk_count += 1 }
    assert_equal 5, blk_count
  end

  def test_to_s
    bit_array    = SparseBitArray.new(8)
    bit_array[0] = bit_array[7] = true
    assert_equal '10000001', bit_array.to_s
  end

  def test_xor
    bit_array1    = SparseBitArray.new(4)
    bit_array2    = SparseBitArray.new(8)
    bit_array1[0] = bit_array1[1] = true
    bit_array2[0] = bit_array2[2] = true
    bit_array     = bit_array1 ^ bit_array2
    assert_equal '01100000', bit_array.to_s

    bit_array = bit_array2 ^ bit_array1
    assert_equal '01100000', bit_array.to_s
  end

  def test_or
    bit_array1    = SparseBitArray.new(4)
    bit_array2    = SparseBitArray.new(8)
    bit_array1[0] = bit_array1[1] = true
    bit_array2[0] = bit_array2[2] = true
    bit_array     = bit_array1 | bit_array2
    assert_equal '11100000', bit_array.to_s

    bit_array = bit_array2 | bit_array1
    assert_equal '11100000', bit_array.to_s
  end


  def test_and
    bit_array1    = SparseBitArray.new(4)
    bit_array2    = SparseBitArray.new(8)
    bit_array1[0] = bit_array1[1] = true
    bit_array2[0] = bit_array2[2] = true
    bit_array     = bit_array1 & bit_array2
    assert_equal '10000000', bit_array.to_s

    bit_array = bit_array2 & bit_array1
    assert_equal '10000000', bit_array.to_s
  end

  def test_block_level_1
    assert_equal 1, SparseBitArray.new(1).stats[:block1_size]
    assert_equal 1, SparseBitArray.new(2).stats[:block1_size]
    assert_equal 1, SparseBitArray.new((1 << 16) - 1).stats[:block1_size]
    assert_equal 2, SparseBitArray.new((1 << 16)).stats[:block1_size]
    assert_equal 2, SparseBitArray.new(2 * (1 << 16) - 1).stats[:block1_size]
    assert_equal 4, SparseBitArray.new(2 * (1 << 16)).stats[:block1_size]
    assert_equal 4, SparseBitArray.new(3 * (1 << 16)).stats[:block1_size]
    assert_equal 8, SparseBitArray.new(4 * (1 << 16)).stats[:block1_size]
    assert_equal 8, SparseBitArray.new(7 * (1 << 16)).stats[:block1_size]
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
