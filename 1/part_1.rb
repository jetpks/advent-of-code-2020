#!/usr/bin/env ruby
# frozen_string_literal: true

numbers = []
from2020 = []

File.readlines('input').each do |number_string|
  number = number_string.to_i
  numbers << number
  from2020 << 2020 - number
end

puts (from2020 & numbers).reduce(&:*)
