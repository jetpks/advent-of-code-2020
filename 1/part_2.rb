#!/usr/bin/env ruby
# frozen_string_literal: true

# The Elves in accounting are thankful for your help; one of them even offers
# you a starfish coin they had left over from a past vacation. They offer you a
# second one if you can find three numbers in your expense report that meet the
# same criteria.
#
# Using the above example again, the three entries that sum to 2020 are 979,
# 366, and 675. Multiplying them together produces the answer, 241861950.
#
# In your expense report, what is the product of the three entries that sum to
# 2020?

numbers = File.readlines('input').map(&:to_i)

# ok, what's the naive solution here?
#
# brute force systematic where you take each number and combine it with two
# others until you find a combination that is 2020, but that's boring.
#
# I could also just grab three at random until they add to 2020. Yeah, gonna do
# that.

loop do
  sample = numbers.sample(3)
  if sample.reduce(&:+) == 2020
    puts sample.reduce(&:*)
    break
  end
end
