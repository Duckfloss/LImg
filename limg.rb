#!/usr/bin/env ruby

# This is the Lee's image parser script.

require 'optparse'
require 'ostruct'
#require 'RMagick'



class Parser

	FORMATS = ["all","t","thumb","thumbnail","med","medium","lg","large","sw","swatch"]

	def self.parse(args)
		options = OpenStruct.new
		options.format = "all"
		options.eci = false
		options.source = nil
		options.dest = nil
		options.size = nil
		options.verbose = false

		opt_parser = OptionParser.new do |opt|
			opt.banner = "Usage: limg.rb [options]"
			opt.separator ""
			opt.separator "Options:"

			opt.on("-e", "--eci", "Only parse pic(s) to ECI's image directory") do
				options.eci = true
			end

			opt.on("--source SOURCE", "Sets source file or directory") do |source|
				# Validate source
				if !Dir.exist?(source)
					if File.exist?(source)
						options.source = { "file"=>source }
					end
				else
					options.source = { "dir"=>source }
				end

				if options.source.nil?
					puts "error" #error
				end
			end

			opt.on("--dest DEST", "Sets destination directory") do |dest|
				if !Dir.exist?(dest)
					puts "error" #error
				else
					options.dest = dest
				end
			end

			opt.on("--size WXH", "Sets custom output size", "  format should be similar to \"125x125\"") do |size|
				splitter = size.downcase.index('x')
				if splitter.nil?
					puts "error" #error
				end
				options.size = size.split('x').each do |i|
					if i.to_i < 0
						puts "error" #error
					end
				end
			end

			opt.on("-fFORMAT", "--format FORMAT", "Select a single output format", "  output sizes are t, sw, med, and lg", "  default is \"all\"") do |format|
				if FORMATS.index(format.downcase).nil?
					puts "error" #error
				else
					options.format = format.downcase
				end
			end

			opt.on("-v", "--verbose", "Run chattily (or not)") do |v|
				options.verbose = true
			end

			opt.separator ""
			opt.separator "Also:"

			opt.on_tail("-h","--help","Prints this help") do
				puts opt
				exit
			end
		end

		opt_parser.parse!(args)
		options
	end
end

class Image_Chopper

	def initialize(*args)
		
	end
end


if __FILE__ == $0

options = Parser.parse(ARGV)
puts options.to_h



end



=begin
			opt.on("-i", "--inplace [EXTENSION]", "Edit ARGV files in place", " (make backup if EXTENSION supplied)") do |ext|
				options.inplace = true
				options.extension = ext || ''
				options.extension.sub!(/\A\.?(?=.)/, ".")
			end

			opt.on("--delay N", Float, "Delay N seconds before executing") do |n|
				options.delay = n
			end

			opt.on("-t", "--time [TIME]", Time, "Begin execution at given time") do |time|
				options.time = time
			end

			opt.on("-F", "--irs [OCTAL]", OptionParser::OctalInteger, "Specify record separator (default \\0)") do |rs|
				options.record_separator = rs
			end

			opt.on("--list x,y,z", Array, "Sample list of arguments") do |list|
				options.list = list
			end

			code_list = (CODE_ALIASES.keys + CODES).join(',')
			opt.on("--code CODE", CODES, CODE_ALIASES, "Select encoding", " (#{code_list})") do |encoding|
				options.encoding = encoding
			end

			opt.on("--type [TYPE]", [:text, :binary, :auto], "Select transfer type (text,binary,auto)") do |t|
				options.tx = t
			end
=end

#			-h, --help, Prints help text
#			-v, --verbose, Verbose
#			-e, --eci, Only parse pic(s) to ECI's image directory
#			--source SOURCE, Sets source file or directory
#			--dest DEST, Sets destination directory
#			--size WXH, Sets custom output size
#			-f, --format NAME, Select a single output size
#				(t,sw,med,lg)
