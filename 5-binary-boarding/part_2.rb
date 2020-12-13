#!/usr/bin/env ruby
# frozen_string_literal: true

###
# Ding! The "fasten seat belt" signs have turned on. Time to find your seat.

# It's a completely full flight, so your seat should be the only missing
# boarding pass in your list. However, there's a catch: some of the seats at
# the very front and back of the plane don't exist on this aircraft, so they'll
# be missing from your list as well.

# Your seat wasn't at the very front or back, though; the seats with IDs +1 and
# -1 from yours will be in your list.

# What is the ID of your seat?

###
# Solution

# Ok we're gonna have to sort. No getting around that. I'd like to iterate
# using a sliding window of 3, then detect if a seat_id is missing in the
# middle of the window

class SeatLocator
  COLS = (0..7).to_a
  ROWS = (0..127).to_a
  attr_reader :row_map, :col_map

  def initialize(map)
    @row_map = map[0..6]
    @col_map = map[7..9]
  end

  def col_id
    @col_id ||= COLS.dup.tap do |remaining|
      col_map.chars.each do |direction|
        traverse_map(%w[R L], remaining, direction)
      end
    end.first
  end

  def row_id
    @row_id ||= ROWS.dup.tap do |remaining|
      row_map.chars.each do |direction|
        traverse_map(%w[B F], remaining, direction)
      end
    end.first
  end

  def seat_id
    @seat_id ||= row_id * COLS.count + col_id
  end

  def traverse_map(legend, remaining, direction)
    case direction
    when legend.first
      remaining.shift(remaining.count / 2)
    when legend.last
      remaining.pop(remaining.count / 2)
    end
  end
end

File
  .readlines('input')
  .map { |map| SeatLocator.new(map) }
  .sort_by(&:seat_id)
  .each_slice(2) { |s| p s.first.seat_id + 1 if s.map(&:seat_id).reduce(&:-) != -1 }
