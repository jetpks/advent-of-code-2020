#!/usr/bin/env ruby
# frozen_string_literal: true

###
# --- Part Two ---

# Time to check the rest of the slopes - you need to minimize the probability
# of a sudden arboreal stop, after all.

# Determine the number of trees you would encounter if, for each of the
# following slopes, you start at the top-left corner and traverse the map all
# the way to the bottom:

#     Right 1, down 1.
#     Right 3, down 1. (This is the slope you already checked.)
#     Right 5, down 1.
#     Right 7, down 1.
#     Right 1, down 2.

# In the above example, these slopes would find 2, 7, 3, 4, and 2 tree(s)
# respectively; multiplied together, these produce the answer 336.

# What do you get if you multiply together the number of trees encountered on
# each of the listed slopes?

###
# Solution

# I can reuse most of the original solution. Just wrap the whole loop in a
# function that accepts the movement values and returns the quantity of hit
# trees.

# Let's start again with the poorly made circular array.
class PoorlyMadeCircularArray < Array
  def [](index)
    super(index % self.count)
  end

  def []=(index, value)
    super(index % self.count, value)
  end
end

class TreeHitCalculator
  attr_accessor :rows

  def initialize
    @rows = File.readlines('input', chomp: true).map do |row|
      PoorlyMadeCircularArray.new.concat(row.chars)
    end
  end

  def how_many_trees_will_i_hit?(move_x, move_y)
    x, y, hit_tree = 0, 0, 0
    loop do
      x += move_x
      y += move_y
      break if y >= rows.count

      hit_tree += 1 if rows[y][x] == '#'
    end
    hit_tree
  end
end

thc = TreeHitCalculator.new

puts [
  thc.how_many_trees_will_i_hit?(1, 1),
  thc.how_many_trees_will_i_hit?(3, 1),
  thc.how_many_trees_will_i_hit?(5, 1),
  thc.how_many_trees_will_i_hit?(7, 1),
  thc.how_many_trees_will_i_hit?(1, 2)
].reduce(&:*)
