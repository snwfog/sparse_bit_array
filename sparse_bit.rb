class SparseBit
  class IndexOutOfBound < RuntimeError; end
  def initialize(size)
    @@width=1.size*8
    @@max_int=1<<(@@width-2)-1
    w4,w3,w2=6,5,5
    w1=@@width-(w4+w3+w2)
    @tree=Array.new(w1)
    @size=0
  end

  def set(index,bool)
    blocks=_calculate_blocks(index)
    raise IndexOutOfBound if blocks.empty?
    w1,w2,w3,w4=blocks
    t2=@tree[w1]||=Array.new(1<<5)
    t3=t2[w2]||=Array.new(1<<5)
    mask=1<<w4
    if bool
      t3[w3]=t3[w3] ? (t3[w3]|mask) : mask
    else
      mask=~mask
      t3[w3]=t3[w3] ? (t3[w3]&mask) : 0
    end
  end

  def get(index)
    blocks=_calculate_blocks(index)
    raise IndexOutOfBound if blocks.empty?
    w1,w2,w3,w4=blocks
    return unless @tree[w1]
    return unless @tree[w1][w2]
    return unless @tree[w1][w2][w3]
    @tree[w1][w2][w3]&(1<<w4)>0
  end

  private
  def _calculate_blocks(index)
    return [] if index>@@max_int
    w1=index>>(6+5+5)
    w2=index>>(6+5)&((1<<5)-1)
    w3=index>>6&((1<<5)-1)
    w4=index % @@width
    [w1,w2,w3,w4]
  end
end
