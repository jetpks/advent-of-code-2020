# frozen_string_literal: true

require 'set'
require 'pry-byebug'
require 'awesome_print'

# AdventInput provides an interface to a challenge's input file
module AdventInput
  FILE = 'input'

  def split(on)
    text.split(on)
  end

  module_function

  def lines
    @lines ||= File.readlines(FILE, chomp: true)
  end

  def text
    @text ||= File.read(FILE)
  end
end
