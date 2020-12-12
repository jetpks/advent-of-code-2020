#!/usr/bin/env ruby
# frozen_string_literal: true

###
# The line is moving more quickly now, but you overhear airport security
# talking about how passports with invalid data are getting through. Better add
# some data validation, quick!

# You can continue to ignore the cid field, but each other field has strict
# rules about what values are valid for automatic validation:

#     byr (Birth Year) - four digits; at least 1920 and at most 2002.
#     iyr (Issue Year) - four digits; at least 2010 and at most 2020.
#     eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
#     hgt (Height) - a number followed by either cm or in:
#         If cm, the number must be at least 150 and at most 193.
#         If in, the number must be at least 59 and at most 76.
#     hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
#     ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
#     pid (Passport ID) - a nine-digit number, including leading zeroes.
#     cid (Country ID) - ignored, missing or not.

# Your job is to count the passports where all required fields are both present
# and valid according to the above rules. Here are some example values:

# byr valid:   2002
# byr invalid: 2003

# hgt valid:   60in
# hgt valid:   190cm
# hgt invalid: 190in
# hgt invalid: 190

# hcl valid:   #123abc
# hcl invalid: #123abz
# hcl invalid: 123abc

# ecl valid:   brn
# ecl invalid: wat

# pid valid:   000000001
# pid invalid: 0123456789

# Here are some invalid passports:

# eyr:1972 cid:100
# hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

# iyr:2019
# hcl:#602927 eyr:1967 hgt:170cm
# ecl:grn pid:012533040 byr:1946

# hcl:dab227 iyr:2012
# ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

# hgt:59cm ecl:zzz
# eyr:2038 hcl:74454a iyr:2023
# pid:3556412378 byr:2007

# Here are some valid passports:

# pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
# hcl:#623a2f

# eyr:2029 ecl:blu cid:129 byr:1989
# iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

# hcl:#888785
# hgt:164cm byr:2001 iyr:2015 cid:88
# pid:545766238 ecl:hzl
# eyr:2022

# iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719

# Count the number of valid passports - those that have all required fields and
# valid values. Continue to treat cid as optional. In your batch file, how many
# passports are valid?

###
# Solution

# This should be pretty straight forward since we already have the Password
# object. Looks like we still care about required fields, so we need that part
# AND a value valudator.
#
# I could add Passport#validate_<field>(value) methods, but I think it makes
# more sense to just break field into its own Field class and let the field
# validations live there.
#
# Once that exists, i'll just call it in Passport#valid?

class Passport < Hash
  REQUIRED_FIELDS = %w[byr ecl eyr hcl hgt iyr pid].freeze

  def ingest_text(passport_data)
    passport_data.split(/\s/).each do |key_value_data|
      parse_field(key_value_data)
    end
    self
  end

  def parse_field(key_value_data)
    key, value = *key_value_data.split(':')
    self[key] = PassportField.new(key, value)
    self
  end

  def valid?
    REQUIRED_FIELDS
      .map { |key| key?(key) && self[key].valid? }
      .reduce { |m, r| m && r }
  end
end

class PassportField
  attr_accessor :type, :value
  def initialize(type, value)
    @type = type
    @value = value
  end

  def valid?
    case type
    when 'byr'
      # (Birth Year) - four digits; at least 1920 and at most 2002.

      # all integers between 1920 and 2002 are 4 digits, so we don't need to
      # test that directly
      value.to_i.between?(1920, 2002)
    when 'iyr'
      # (Issue Year) - four digits; at least 2010 and at most 2020.
      value.to_i.between?(2010, 2020)
    when 'eyr'
      # (Expiration Year) - four digits; at least 2020 and at most 2030.
      value.to_i.between?(2020, 2030)
    when 'hgt'
      # (Height) - a number followed by either cm or in:
      #   If cm, the number must be at least 150 and at most 193.
      #   If in, the number must be at least 59 and at most 76.

      return false unless value.end_with?('cm', 'in')

      unit = value[-2..-1]
      numeric_value = value[0..-3].to_i

      if unit == 'cm'
        numeric_value.between?(150, 193)
      else
        numeric_value.between?(59, 76)
      end
    when 'hcl'
      # (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
      /^#[0-9a-f]{6}$/.match?(value.to_s)
    when 'ecl'
      # (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
      %w[amb blu brn gry grn hzl oth].include?(value)
    when 'pid'
      # (Passport ID) - a nine-digit number, including leading zeroes.
      /^\d{9}$/.match?(value.to_s)
    when 'cid'
      # (Country ID) - ignored, missing or not.
      true
    else
      false
    end
  end
end

puts File
  .read('input')
  .split("\n\n")
  .map { |raw| Passport.new.ingest_text(raw) }
  .select(&:valid?)
  .count
