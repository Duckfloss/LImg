#!/usr/bin/env ruby


def parse_options
  options = {}
  case ARGV[1]
  when "-x"
    options[:x] = ARGV[2]
  when "-y"
    options[:y] = ARGV[2]
  end
  options
end

