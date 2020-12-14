#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/input'

###
# --- Day 7: Handy Haversacks ---

# You land at the regional airport in time for your next flight. In fact, it
# looks like you'll even have time to grab some food: all flights are currently
# delayed due to issues in luggage processing.

# Due to recent aviation regulations, many rules (your puzzle input) are being
# enforced about bags and their contents; bags must be color-coded and must
# contain specific quantities of other color-coded bags. Apparently, nobody
# responsible for these regulations considered how long they would take to
# enforce!

# For example, consider the following rules:

# light red bags contain 1 bright white bag, 2 muted yellow bags.
# dark orange bags contain 3 bright white bags, 4 muted yellow bags.
# bright white bags contain 1 shiny gold bag.
# muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
# shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
# dark olive bags contain 3 faded blue bags, 4 dotted black bags.
# vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
# faded blue bags contain no other bags.
# dotted black bags contain no other bags.

# These rules specify the required contents for 9 bag types. In this example,
# every faded blue bag is empty, every vibrant plum bag contains 11 bags (5
# faded blue and 6 dotted black), and so on.

# You have a shiny gold bag. If you wanted to carry it in at least one other
# bag, how many different bag colors would be valid for the outermost bag? (In
# other words: how many colors can, eventually, contain at least one shiny gold
# bag?)

# In the above rules, the following options would be available to you:

#     A bright white bag, which can hold your shiny gold bag directly.
#     A muted yellow bag, which can hold your shiny gold bag directly, plus some other bags.
#     A dark orange bag, which can hold bright white and muted yellow bags, either of which could then hold your shiny gold bag.
#     A light red bag, which can hold bright white and muted yellow bags, either of which could then hold your shiny gold bag.

# So, in this example, the number of bag colors that can eventually contain at
# least one shiny gold bag is 4.

# How many bag colors can eventually contain at least one shiny gold bag? (The
# list of rules is quite long; make sure you get all of it.)

###
# Solution

# ok, it seems like we need to understand the contains and contained-by
# relationships in order to get the answer. should I just calculate all of
# those up top, or try to do it on the fly from a list of rules?

# maybe Bag that stores its relationships in a Hash for lookup?

# I'm not sure we need the quantity here, but we probably will in part_2.
# /shrug i'll add it when we need it.

class Bag
  RULE_PATTERN = /(?<quantity>\d+)\s(?<color>[\s\w]+)\sbags\.?$/.freeze
  attr_accessor :color, :contains, :contained_by

  def initialize
    @contains = Set.new
    @contained_by = Set.new
  end

  def inform_children(universe)
    contains.each do |contained_color|
      universe[contained_color].contained_by << color
    end
  end

  def self.from(raw)
    new.tap do |bag|
      color_raw, rules_raw = *raw.split('bags contain')
      bag.color = color_raw.rstrip.sub(' ', '_').to_sym

      rules_raw.split(',').each do |rule|
        matches = rule.match(RULE_PATTERN)
        next if matches.nil? || matches['quantity'] == 'no'

        bag.contains << matches['color'].sub(' ', '_').to_sym
      end
    end
  end
end

class BagAncestry
  attr_reader :community, :subject

  def initialize(community:, subject:)
    @community = community
    @seen = Set.new
    @subject = subject
  end

  def ancestors
    require 'pry-byebug'
    binding.pry
    @ancestors ||= ascend(Set.new, [subject])
  end

  def ascend(seen, subjects)
    subjects.each do |sub|
      new_ancestors = community[sub].contained_by.reject { |c| seen.include?(c) }
      next if new_ancestors.count.zero?

      seen += ascend(seen, new_ancestors)
    end
    seen
  end

  private

  attr_reader :seen
end

bags = {}
AdventInput
  .lines
  .each do |line|
    bag = Bag.from(line)
    bags[bag.color] = bag
  end
bags.each_value do |bag|
  bag.inform_children(bags)
end

# How many bag colors can eventually contain at least one shiny gold bag?

# sounds like we need a graph of contained_by chains connected to :shiny_gold,
# then count the nodes
# we're just gonna use an array though.
#
# let's call bags[:shiny_gold].contained_by and chuck those in a
# contains_shiny_gold Array. Then, call contained_by on all of those

p BagAncestry.new(community: bags, subject: :shiny_gold).ancestors.count
