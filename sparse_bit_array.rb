# Sparse bit array for Ruby
# Inspired from https://github.com/brettwooldridge/SparseBitSet
class SparseBitArray
  # include Enumerable

  class IndexOutOfBound < RuntimeError
  end

  WIDTH  = 1.size * 8
  MAX    = 1 << (WIDTH - 2) - 1
  BLOCK4 = 6
  BLOCK3 = 5
  BLOCK2 = 5

  SHIFT3 = BLOCK4
  SHIFT2 = BLOCK4 + BLOCK3
  SHIFT1 = BLOCK4 + BLOCK3 + BLOCK2

  BLOCK1 = WIDTH - SHIFT1

  MASK3 = (1 << BLOCK3) - 1
  MASK2 = (1 << BLOCK2) - 1

  # Not in use
  NULL_BLOCK3 = Array.new(1 << BLOCK3, 0)

  attr_reader :size

  def initialize(size)
    @size = size

    # The minimum block1 size needed to accommodate
    # the bit array's size
    @min_block1 = [size.bit_length - SHIFT1, 0].max
    @block1     = Array.new(1 << @min_block1)
  end

  def set(index)
    block4, mask = get_block4(index), 1 << index % WIDTH
    set_block4(index, block4 ? (block4 | mask) : mask)
  end

  def clear(index)
    block4, mask = get_block4(index), ~(1 << index % WIDTH)
    value        = block4 ? block4 & mask : 0
    value        = nil if value.zero?
    set_block4(index, value)
  end

  def flip(index)
    block4, mask = get_block4(index), 1 << index % WIDTH
    value        = block4 ? block4 ^ mask : mask
    value        = nil if value.zero?
    set_block4(index, value)
  end

  def get(index)
    b1, b2, b3, b4 = _calculate_block_indices(index)
    return false unless @block1[b1] && @block1[b1][b2] && @block1[b1][b2][b3]
    @block1[b1][b2][b3] & (1 << b4) > 0
  end

  def [](index)
    get(index)
  end

  def []=(index, value)
    value ? set(index) : clear(index)
  end

  def ^(other)
    _internal_apply_with(:^, other)
  end

  def |(other)
    _internal_apply_with(:|, other)
  end

  def &(other)
    _internal_apply_with(:&, other)
  end

  # def ~(other)
  #   _internal_apply_with(:~, other)
  # end

  def to_s
    require 'stringio'

    sb = StringIO.new
    each { |block3|
      sb << block3.map { |block4|
        format("%0#{1 << BLOCK4}b", (block4 || 0)).reverse }.join
    }

    # At max there will be just 1 block of extra bits
    # So we are cutting at exactly @size
    sb.string[0...@size]
  end


  def stats
    Hash[
      block1_size: @block1.size,
      block2_size: @block1.flatten(1).count { |b| !b.nil? },
      block3_size: @block1.flatten(2).count { |b| !b.nil? },
    ]
  end

  def each(&blk)
    block3_iterator(&blk)
  end

  def ==(other)
  end

  protected

  def block3_iterator
    index = 0
    while index < @size
      b1, b2, *_ = _calculate_block_indices(index)
      if block2 = @block1[b1]
        if block3 = block2[b2]
          yield block3
        end
        index += 1 << SHIFT2
      else
        index += 1 << SHIFT1
      end
    end
  end

  # Will set the block4 of this index
  def set_block4(index, value)
    b1, b2, b3, *_ = _calculate_block_indices(index)
    block2         = @block1[b1] ||= Array.new(1 << BLOCK2)
    block3         = block2[b2] ||= Array.new(1 << BLOCK3)
    block3[b3]     = value
  end

  # Will return the block4 of this index
  def get_block4(index)
    b1, b2, b3, *_ = _calculate_block_indices(index)
    return unless @block1[b1] && @block1[b1][b2]
    @block1[b1][b2][b3]
  end

  private

  def _calculate_block_indices(index)
    raise IndexOutOfBound if index >= @size || index < 0
    b1 = index >> SHIFT1
    b2 = index >> SHIFT2 & MASK2
    b3 = index >> BLOCK4 & MASK3
    b4 = index % WIDTH
    [b1, b2, b3, b4]
  end

  def _internal_apply_with(op, other)
    index     = 0
    size      = [other.size, @size].max
    bit_array = SparseBitArray.new(size)
    while index < size
      l = get_block4(index) || 0
      r = other.get_block4(index) || 0
      bit_array.set_block4(index, l.__send__(op, r))
      index += 1 << SHIFT3
    end

    bit_array
  end
end
