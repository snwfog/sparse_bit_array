require 'bitarray'
require 'benchmark/ips'

require_relative './sparse_bit_array'

Benchmark.ips do |x|
  size = 1 << 17
  x.report('sparse bitarray:') do
    bit_array = SparseBitArray.new(size)
    size.times do |i|
      bit_array[i] = true
      bit_array[i]
    end
  end

  x.report('bitarray:') do
    bit_array = BitArray.new(size)
    size.times do |i|
      bit_array[i] = 1
      bit_array[i]
    end
  end

  x.compare!
end



