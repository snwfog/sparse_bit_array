# Sparse bit array for Ruby
# Inspired from https://github.com/brettwooldridge/SparseBitSet
class SparseBitArray
  class IndexOutOfBound < RuntimeError; end

  WIDTH  = 1.size * 8
  MAX    = 1 << (WIDTH - 2) - 1
  BLOCK4 = 6
  BLOCK3 = 5
  BLOCK2 = 5
  BLOCK1 = WIDTH - (BLOCK4 + BLOCK3 + BLOCK2)

  def initialize(size)
    @size = size

    # The minimum block1 size needed to accommodate
    # the bit array's size
    @min_block1 = [size.bit_length - (BLOCK4 + BLOCK3 + BLOCK2), 0].max
    @tree       = Array.new(1 << @min_block1)
  end

  def set(index)
    b1, b2, b3, b4 = _calculate_block_indices(index)
    t2             = @tree[b1] ||= Array.new(1 << BLOCK2)
    t3             = t2[b2] ||= Array.new(1 << BLOCK3)
    mask           = 1 << b4
    t3[b3]         = t3[b3] ? (t3[b3] | mask) : mask
  end

  def clear(index)
    b1, b2, b3, b4 = _calculate_block_indices(index)
    t2             = @tree[b1] ||= Array.new(1 << BLOCK2)
    t3             = t2[b2] ||= Array.new(1 << BLOCK3)

    if t3[b3]
      t3[b3] &= ~(1 << b4)
      t3[b3] = nil if t3[b3].zero?
    end
  end

  def get(index)
    b1, b2, b3, b4 = _calculate_block_indices(index)
    return false unless @tree[b1] && @tree[b1][b2] && @tree[b1][b2][b3]
    @tree[b1][b2][b3] & (1 << b4) > 0
  end

  def [](index)
    get(index)
  end

  def []=(index, value)
    value ? set(index) : clear(index)
  end

  def stats
    Hash[
      block1_size: @tree.count { |b| !b.nil? },
      block2_size: @tree.flatten(1).count { |b| !b.nil? },
      block3_size: @tree.flatten(2).count { |b| !b.nil? },
    ]
  end

  private

  def _calculate_block_indices(index)
    raise IndexOutOfBound if index >= @size || index < 0
    b1 = index >> (BLOCK4 + BLOCK3 + BLOCK2)
    b2 = index >> (BLOCK4 + BLOCK3) & ((1 << BLOCK2) - 1)
    b3 = index >> (BLOCK4) & ((1 << BLOCK2) - 1)
    b4 = index % WIDTH
    [b1, b2, b3, b4]
  end
end
