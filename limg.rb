#!/usr/bin/env ruby

# This is the Lee's image parser script.
#			-h, --help, Prints help text
#			-v, --verbose, Verbose
#			-e, --eci, Only parse pic(s) to ECI's image directory
#			--source SOURCE, Sets source file or directory
#			--dest DEST, Sets destination directory
#			--size WXH, Sets custom output size
#			-f, --format NAME, Select a single output size
#				(t,sw,med,lg)

require 'optparse'
require 'ostruct'
require 'RMagick'
include Magick
require 'pry'

# Default destination directories
$dest = "R:/RETAIL/IMAGES/4Web"
$eci = "R:/RETAIL/RPRO/Images/Inven"
$basearray = []
$formats = {
		"lg"=>1050,
		"med"=>350,
		"sw"=>350, # this is temporary til I figure out how to automate it
		"t"=>100
	}


class Parser

	def self.parse(args)
		options = OpenStruct.new
		options.format = ["all"]
		options.eci = false
		options.source = "C:/Documents and Settings/pos/My Documents/Downloads/WebAssets"
		options.dest = nil
		options.verbose = false

		opt_parser = OptionParser.new do |opt|
			opt.banner = "Usage: limg.rb [options]"
			opt.separator ""
			opt.separator "Options:"

			opt.on("--source SOURCE", "Sets source file or directory", "  default is Downloads/WebAssets") do |source|
			if File.exist?(source)
						options.source = source
				else
					puts "source error" #error
				end
			end

			opt.separator ""

			opt.on("--dest DEST", "Sets destination directory", "  defaults are R:/RETAIL/IMAGES/4Web", "  and R:/RETAIL/RPRO/Images/Inven") do |dest|
				if !Dir.exist?(dest)
					puts "destination error" #error
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
				if formats == ["all"]
					formats = $formats.keys
				else
					options.format.clear
					formats.each do |format|
						format.strip!
						if !$formats.has_key?(format)
							puts "format error" #error
							exit
						else
							options.format << format
						end
					end
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

def chopit(image,options)

	$outputs = []

	# Parse filename
	if File.directory?(options.source)
		path = options.source
	else
		path = File.dirname(image)
		image = File.basename(image)
	end
	image_w_path = path + "/" + image
	filebase = image.slice(/^[A-Z]{16}/)
	fileattr = image.slice(/(?<=\_)([A-Za-z0-9\_]+)(?=\.)/)
	if !$basearray.include?(filebase)
		$basearray << filebase
	end

	# Begin reporting
	$report = "#{image}"

	# ECI
	if options.eci
		if $basearray.include?(filebase)
			$outputs << { size: 350, dest: $eci, name: "#{filebase}.jpg" }
			$outputs << { size: 100, dest: $eci, name: "#{filebase}t.jpg" }
		end
	end

	# FORMAT
	if options.format
		if options.format.include?("all")
			options.format = $formats.keys
		end
		options.format.each do |format|
			if fileattr.nil?
				$outputs << { size: $formats[format], dest: $dest, name: "#{filebase}_#{format}.jpg" }
			else
				$outputs << { size: $formats[format], dest: $dest, name: "#{filebase}_#{fileattr}_#{format}.jpg" }
			end
		end
		if !fileattr.nil?
			$outputs << { size: 1050, dest: $dest, name: "#{filebase}_lg.jpg" }
		end
	end # format loop

	# Sort the $outputs array by size
	$outputs.sort! { |x,y| x[:size] <=> y[:size] }
	$outputs.reverse!

	# Create new image object and set defaults
	image = ImageList.new(image_w_path) do
		self.background_color = "#ffffff"
		self.gravity = CenterGravity
	end

	# Preformat imgage
	# If the image is CMYK, change it to RGB
	color_profile = "C:/WINDOWS/system32/spool/drivers/color/sRGB Color Space Profile.icm"
	if image.colorspace == Magick::CMYKColorspace
		image = image.add_profile(color_profile)
	end

	# If the image has alpha channel transparency, fill it with background color
	if image.alpha?
		image.alpha(BackgroundAlphaChannel)
	end

	# If the image size isn't a square, make it a square
	img_w = image.columns
	img_h = image.rows
	ratio = img_w.to_f/img_h.to_f
	if ratio < 1
		x = img_h/2-img_w/2
		image = image.extent(img_h,img_h,x=-x,y=0)
	elsif ratio > 1
		y = img_w/2-img_h/2
		image = image.extent(img_w,img_w,x=0,y=-y)
	end

	# Chop up image
	$outputs.each do |output|
		# resize(image,size)
		imgout = image.resize(output[:size],output[:size])
		write_file(imgout, "#{output[:dest]}/#{output[:name]}")
		if output[:dest] == "R:/RETAIL/RPRO/Images/Inven"
			$report << "\n\tSaved to ECI: #{output[:name]}"
		else
			$report << "\n\tSaved to dest: #{output[:name]}"
		end
		
		# Killin it
		imgout.destroy!
	end

	# Killin it (Part 2)
	image.destroy!
	GC.start

	# Reporting
	if options.verbose
		puts "\n\n"
		puts $report << "\n"
		$total -= 1
		puts "#{$total} images left to parse\n"
	end
end

def write_file(image,dest)
	image.write(dest) do
		self.quality = 80
		self.density = "72x72"
	end
end

def piclist(source)
	# SOURCE
	if File.directory?(source)
		images = Dir.entries(source)
		images.keep_if { |file| file =~ /\.jpg$|\.png$|\.jpeg$|\.gif$/ }
	elsif File.file?(source)
		if [".jpg", ".png", ".jpeg", ".gif"].include?(File.extname(source))
			images = [ source ]
		else
			raise "piclist error" #error
		end
	else
		raise "piclist error" #error
	end
	images
end

def validate(options)
	# DESTINATION
	if options.dest
		dest = options.dest
	end
	# Reporting
	if options.verbose
		puts "Destination: #{dest}\n"
	end
	options
end

#ARGV << "--source \"C:/Documents and Settings/pos/My Documents/Downloads/WebAssets/PAIEADAJAPJKNCOO_Lime.jpg\""
#options = validate(Parser.parse(ARGV))
#binding.pry

def run
#if __FILE__ == $0
	options = validate(Parser.parse(ARGV))
	list = piclist(options.source)
	total = list.length
	$total = list.length

	# Input report
	inreport = "Parsing "
	if $total > 1
		inreport << "#{$total} files in "
	end
	inreport << "#{options.source}\n"
	puts inreport

	# Image processing loop
	while !list.empty?
		image = list.shift
		chopit(image,options)
	end # Image processing loop

	# Output report
	outreport = "#{total} images processed."
	puts outreport
end
