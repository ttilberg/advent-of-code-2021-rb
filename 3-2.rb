class DiagnosticReport
  attr_reader :report
  attr_reader :gamma, :epsilon
  attr_reader :oxygen_generator_rating, :co2_scrubber_rating

  def initialize(report)
    @report = report.split.map{|line| line.chars.map(&:to_i)}
    @gamma = nil
    @epsilon = nil
    @oxygen_generator_rating = nil
    @co2_scrubber_rating = nil

    scan!
  end

  def power_consumption
    gamma * epsilon
  end

  def life_support_rating
    co2_scrubber_rating * oxygen_generator_rating
  end

  def to_h
    {
      gamma: gamma,
      epsilson: epsilon,
      power_consumption: power_consumption,
      oxygen_generator_rating: oxygen_generator_rating,
      co2_scrubber_rating: co2_scrubber_rating,
      life_support_rating: life_support_rating
    }
  end

  private

  # Transpose the bit array so we can scan each position
  # For each position, the `gamma` bit is whatever bit has highest frequency,
  #   and the `epsilson` bit is the other.
  # Convert the bits back to integers.
  def scan!
    oxygen_generator_candidates = Array.new(report.size) { 1 }
    co2_scrubber_candidates = Array.new(report.size) { 1 }

    @gamma, @epsilon = report.transpose.map do |bits|
      frequency = bits.tally
      less, more = frequency.sort_by {|_bit, freq| freq }.map(&:first)

      unless @oxygen_generator_rating
        candidates = bits.select.with_index {|_bit, i| oxygen_generator_candidates[i] == 1 }
        bit_filter = bits_by_frequency(candidates).last

        # turn off bits unless it's a winner
        # There's gotta be some clever bit masking move to be applied here...
        bits.each.with_index do |bit, i|
          oxygen_generator_candidates[i] = 0 unless bit == bit_filter
        end

        if oxygen_generator_candidates.select{|bit| bit == 1}.size == 1
          @oxygen_generator_rating = report[oxygen_generator_candidates.find_index{|bit| bit == 1}].join.to_i(2)
        end

      end

      unless @co2_scrubber_rating
        candidates = bits.select.with_index {|_bit, i| co2_scrubber_candidates[i] == 1 }
        bit_filter = bits_by_frequency(candidates).first

        bits.each.with_index do |bit, i|
          co2_scrubber_candidates[i] = 0 unless bit == bit_filter
        end

        if co2_scrubber_candidates.select{|bit| bit == 1}.size == 1
          @co2_scrubber_rating = report[co2_scrubber_candidates.find_index{|bit| bit == 1}].join.to_i(2)
        end
      end        

      [more, less]
    end.transpose.map(&:join).map{|bits| bits.to_i(2)}
  end

  def bits_by_frequency(bits)
    bits_freq = bits.tally

    if bits_freq.values.reduce(&:eql?)
      [0, 1]
    else
      bits_freq.sort_by{|_bit, freq| freq}.map(&:first)
    end
  end
end

report = DiagnosticReport.new(File.read('data/3.txt'))
puts report.to_h
