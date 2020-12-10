#!/usr/bin/env ruby
# frozen_string_literal: true

###
# --- Part Two ---
#
# While it appears you validated the passwords correctly, they don't seem to be
# what the Official Toboggan Corporate Authentication System is expecting.
#
# The shopkeeper suddenly realizes that he just accidentally explained the
# password policy rules from his old job at the sled rental place down the
# street! The Official Toboggan Corporate Policy actually works a little
# differently.
#
# Each policy actually describes two positions in the password, where 1 means
# the first character, 2 means the second character, and so on. (Be careful;
# Toboggan Corporate Policies have no concept of "index zero"!) Exactly one of
# these positions must contain the given letter. Other occurrences of the
# letter are irrelevant for the purposes of policy enforcement.
#
# Given the same example list from above:
#
#     1-3 a: abcde is valid: position 1 contains a and position 3 does not.
#     1-3 b: cdefg is invalid: neither position 1 nor position 3 contains b.
#     2-9 c: ccccccccc is invalid: both position 2 and position 9 contain c.
#
# How many passwords are valid according to the new interpretation of the
# policies?

###
# Solution

# REMEMBER, INDEX STARTS AT 1!
# This direction seems important: 'Exactly one of these positions must contain
# the given letter' Do they mean the other position can't? Yes, it's in the
# example

class Policy
  attr_reader :first_position, :second_position, :character

  def initialize(raw)
    # Raw should be just the component before the : in the input
    parse(raw)
  end

  def parse(raw)
    parts = raw.split(' ')
    @first_position, @second_position = *parts.first.split('-').map { |i| i.to_i - 1 }
    @character = parts.last
  end

  def valid?(password)
    (password[first_position] == character) ^ (password[second_position] == character)
  end
end

qty_valid = 0
File.readlines('input', chomp: true).each do |input|
  policy, password = *input.split(':')
  qty_valid += 1 if Policy.new(policy).valid?(password.strip)
end
puts qty_valid

# This code is ugly :)
