#!/usr/bin/env ruby

# This is the Lee's image parser script.

require 'optparse'
require 'ostruct'
require 'RMagick'
include Magick


class Parser

	FORMATS = ["all","t","med","lg","sw"]

	def self.parse(args)
		options = OpenStruct.new
		options.format = ["all"]
		options.eci = false
		options.source = nil
		options.dest = nil
		options.verbose = false

		opt_parser = OptionParser.new do |opt|
			opt.banner = "Usage: limg.rb [options]"
			opt.separator ""
			opt.separator "Options:"

			opt.on("--source SOURCE", "Sets source file or directory", "  default is Downloads/WebAssets") do |source|
				# Validate source
				if !File.directory?(source)
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

			opt.separator ""

			opt.on("--dest DEST", "Sets destination directory", "  defaults are R:/RETAIL/IMAGES/4Web", "  and R:/RETAIL/RPRO/Images/Inven") do |dest|
				if !Dir.exist?(dest)
					puts "error" #error
				else
					options.dest = dest
				end
			end

			opt.separator ""

			opt.on("-e", "--eci", "Parses pic(s) to ECI's directory", "  as well as to default or selected destination") do
				options.eci = true
			end

			opt.separator ""

			opt.on("-fFORMAT", "--format FORMAT", Array, "Select output formats", "  accepts comma-separated string", "  output sizes are t,sw,med,lg", "  default is \"all\"") do |formats|
				formats.each do |format|
					if FORMATS.index(format.downcase).nil?
						puts "error" #error
						exit
					end
					options.format = formats
				end
			end

			opt.separator ""

			opt.on("-v", "--verbose", "Run chattily (or not)", "  default runs not verbosely") do |v|
				options.verbose = true
			end

			opt.separator ""

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

	FORMATS = {
		"lg"=>1050,
		"med"=>350,
		"sw"=>350, # this is temporary til I figure out how to automate
		"t"=>100
	}

	def initialize(options)
		# Default destination directory
		dest = "R:/RETAIL/IMAGES/4Web"
		eci = "R:/RETAIL/RPRO/Images/Inven"
		# basearray lets us avoid duplicate output
		$basearray = []

		# SOURCE
		if options.source.nil? 
			options.source = { "dir" => "C:/Documents and Settings/pos/My Documents/Downloads/WebAssets" }
		end
		if options.source.key?("dir")
			images = Dir.entries(options.source["dir"])
			images.keep_if { |file| file =~ /\.jpg$|\.png$|\.jpeg$|\.gif$/ }
		elsif options.source.key?("file")
			images = [ options.source["file"] ]
		else
			puts "error" #error
		end

		# Reporting
		if options.verbose
			puts "Source: #{options.source.values[0]}\n"
		end

		# Image processing loop
		images.each do |image|
			# register output array
			$outputs = []

			# Parse filename
			filename = image.slice(File.dirname(image).length+1..-1)
			filebase = filename.slice(/^[A-Z]{16}/)
			fileattr = filename.slice(/(?<=\_)([A-Za-z0-9\_]+)(?=\.)/)
			if !$basearray.include?(filebase)
				$basearray << filebase
			end

			# DESTINATION
			if options.dest
				dest = options.dest
			end
			# Reporting
			if options.verbose
				puts "Destination: #{dest}\n"
			end

			# Begin reporting
			$report = "\t#{filename}"

			# ECI
			if options.eci
				# Reporting
				if options.verbose
					puts "ECI parsing is on\n"
				end
				if !$basearray.include?(filebase)
					$report << "\n\t  exists in ECI directory"
					break
				else
					$outputs << { size: 1050, dest: dest, name: "#{filebase}_lg.jpg" }
					$outputs << { size: 350, dest: eci, name: "#{filebase}.jpg" }
					$outputs << { size: 100, dest: eci, name: "#{filebase}t.jpg" }
				end
			end

			# FORMAT
			if options.format
				if options.format.include?("all")
					options.format = FORMATS.keys
				end
				options.format.each do |format|
					$outputs << { size: FORMATS[format], dest: dest, name: "#{filebase}_#{fileattr}_#{format}.jpg" }
				end
			end # format loop

			# Sort the $outputs array by size
			$outputs.sort! { |x,y| x[:size] <=> y[:size] }
			$outputs.reverse!

			# Preformat imgage
			image = preformat(image)
			# Chop up images
			$outputs.each do |output|
				ximg = resize( image,output[:size] )
				$report << "\n\t  Resized to #{output[:size]}x#{output[:size]}"
				write_file(ximg, "#{output[:dest]}/#{output[:name]}")
				$report << "\n\t  Saved as: #{output[:name]}"
			end

			# Reporting
			if options.verbose
				puts "\t################################\n"
				puts $report << "\n"
			end
		end # image loop
	end

	def preformat(img)
		# Create new image object and set defaults
		cat = ImageList.new($test) do
			self.background_color = "#ffffff"
			self.gravity = CenterGravity
		end

		# If the image is CMYK, change it to RGB
		color_profile = "C:/WINDOWS/system32/spool/drivers/color/sRGB Color Space Profile.icm"
		if cat.colorspace == Magick::CMYKColorspace
			$report << "\n\t  Colors: #{cat.colorspace} -> #{color_profile}"
			cat = cat.add_profile(color_profile)
		end

		# If the image has alpha channel transparency, fill it with background color
		if cat.alpha?
			$report << "\n\t  Alpha: Transparent -> #{cat.background_color}"
			cat.alpha(BackgroundAlphaChannel)
		end

		# If the image size isn't a square, make it a square
		img_w = cat.columns
		img_h = cat.rows
		ratio = img_w.to_f/img_h.to_f
		if ratio < 1
			$report << "\n\t  Size: #{img_w}x#{img_h} -> #{img_h}x#{img_h}"
			x = img_h/2-img_w/2
			cat = cat.extent(img_h,img_h,x=-x,y=0)
		elsif ratio > 1
			$report << "\n\t  Size: #{img_w}x#{img_h} -> #{img_w}x#{img_w}"
			y = img_w/2-img_h/2
			cat = cat.extent(img_w,img_w,x=0,y=-y)
		end
		cat
	end

	def resize(cat,size)
		cat = cat.resize(size,size)
	end

	def write_file(cat,dest)
		cat.write(dest) do
			self.quality = 80
			self.density = "72x72"
		end
	end

end

$test = "C:/Documents and Settings/pos/Desktop/test/in/PAIEADNFAGBOMIOE_gray.png"
$tgt = "C:/Documents and Settings/pos/Desktop/test/in/PAIEADNFAGBOMIOE_grayOUT.jpg"


if File.exist?($tgt)
	File.delete($tgt)
end


if __FILE__ == $0

options = Parser.parse(ARGV)
puts options.to_h
Image_Chopper.new(options)

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
