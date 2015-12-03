#!/usr/bin/env ruby

# This is the Lee's image parser script.


def parse_options
  options = {}
  case ARGV[1]
  when "-h"
    options[:h] = ARGV[2] # Prints help text
  when "-y"
    options[:y] = ARGV[2]
  when "-f"
    options[:f] = ARGV[2] # Sets file name
  when "-d"
    options[:f] = ARGV[2] # Sets directory name
  end
  options
end

