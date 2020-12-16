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
  attr_reader :color, :rules, :parents

  def initialize(color, rules = {})
    @color = color
    @parents = []
    @rules = rules.freeze
  end

  def children
    rules.keys
  end

  def meet_parent(color)
    @parents << color
  end

  def inform_children(universe)
    contains.each do |contained_color|
      universe[contained_color].contained_by << color
    end
  end
end

class PorterIdentificationError < StandardError; end
class Porter
  RULE_PATTERN = /(?<quantity>\d+|no)\s(?<color>[\s\w]+)\sbags?\.?$/.freeze
  attr_reader :inventory

  def initialize
    @inventory = {}
  end

  def map_child_to_parent_relationships
    inventory.values.each do |bag|
      binding.pry if bag.is_a? Array
      bag.children.each do |c|
        ## DEBUG
        binding.pry unless inventory.key?(c)

        inventory[c].meet_parent(bag.color)
      end
    end
  end

  def lineage(subject)
    [].tap do |generations|
      # make the zeroeth item the subject so the indices match the generation
      generations << Set.new([subject])
      # binding.pry
      loop do
        last = generations.last
        break if last.count.zero?

        current = Set.new
        last.each { |member| current += inventory[member].parents }
        generations << current
      end
    end
  end

  def ingest(raw)
    color_raw, rules_raw = *raw.split('bags contain')

    color = parse_color(color_raw)
    rules = parse_rules(rules_raw)

    inventory[color] = Bag.new(color, rules)
  end

  def parse_color(color_raw)
    color_raw.rstrip.sub(' ', '_').to_sym
  end

  def parse_rules(rules_raw)
    {}.tap do |rules|
      rules_raw.split(',').map do |rule_raw|
        matches = rule_raw.match(RULE_PATTERN)

        if matches.nil?
          binding.pry
          raise PorterIdentificationError, "Could not parse rule from '#{rule_raw}'; Matches: #{matches}"
        end

        next if matches['quantity'] == 'no'

        rules[parse_color(matches['color'])] = matches['quantity']
      end
    end
  end
end

porter = Porter.new
AdventInput.lines.each { |line| porter.ingest(line) }
porter.map_child_to_parent_relationships
# We're not supposed to have to flatten/sort/unique, but this produced the
# right answer, so we're gonna leave it there.
p porter.lineage(:shiny_gold).map(&:to_a).flatten.sort.uniq.count - 1
