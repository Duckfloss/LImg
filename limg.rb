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
		"sw"=>350, # this is temporary til I figure out how to automate it
		"t"=>100
	}

	def initialize(options)
		# Default destination directories
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

		# DESTINATION
		if options.dest
			dest = options.dest
		end
		# Reporting
		if options.verbose
			puts "Destination: #{dest}\n"
		end


		# Image processing loop
		images.each do |image|
			# register output array
			$outputs = []

			# Parse filename
			if options.source.key?("file")
				filename = image.slice(File.dirname(image).length+1..-1)
			else
				filename = image
				image = "#{options.source['dir']}/#{image}"
			end
			filebase = filename.slice(/^[A-Z]{16}/)
			fileattr = filename.slice(/(?<=\_)([A-Za-z0-9\_]+)(?=\.)/)
			if !$basearray.include?(filebase)
				$basearray << filebase
			end

			# Begin reporting
			$report = "#{filename}"

			# ECI
			if options.eci
				# Reporting
				if options.verbose
					#puts "ECI parsing is on\n"
				end
				if !$basearray.include?(filebase)
					#$report << "\n\t  exists in ECI directory"
					break
				else
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
					if fileattr.nil?
						$outputs << { size: FORMATS[format], dest: dest, name: "#{filebase}_#{format}.jpg" }
					else
						$outputs << { size: FORMATS[format], dest: dest, name: "#{filebase}_#{fileattr}_#{format}.jpg" }
					end
				end
				if !fileattr.nil?
					$outputs << { size: 1050, dest: dest, name: "#{filebase}_lg.jpg" }
				end
			end # format loop

			# Sort the $outputs array by size
			$outputs.sort! { |x,y| x[:size] <=> y[:size] }
			$outputs.reverse!

			# Preformat imgage
			image = preformat(image)

			# Chop up image
			$outputs.each do |output|
				imgout = resize( image,output[:size] )
				#$report << "\n\t  Resized to #{output[:size]}x#{output[:size]}"
				write_file(imgout, "#{output[:dest]}/#{output[:name]}")
				if output[:dest] == "R:/RETAIL/RPRO/Images/Inven"
					$report << "\n\tSaved to ECI: #{output[:name]}"
				else
					$report << "\n\tSaved to dest: #{output[:name]}"
				end
			end

			# Reporting
			if options.verbose
				puts "\n\n"
				puts $report << "\n"
			end
		end # image loop
	end

	def preformat(img)
		# Create new image object and set defaults
		cat = ImageList.new(img) do
			self.background_color = "#ffffff"
			self.gravity = CenterGravity
		end

		# If the image is CMYK, change it to RGB
		color_profile = "C:/WINDOWS/system32/spool/drivers/color/sRGB Color Space Profile.icm"
		if cat.colorspace == Magick::CMYKColorspace
			#$report << "\n\t  Colors: #{cat.colorspace} -> #{color_profile}"
			cat = cat.add_profile(color_profile)
		end

		# If the image has alpha channel transparency, fill it with background color
		if cat.alpha?
			#$report << "\n\t  Alpha: Transparent -> #{cat.background_color}"
			cat.alpha(BackgroundAlphaChannel)
		end

		# If the image size isn't a square, make it a square
		img_w = cat.columns
		img_h = cat.rows
		ratio = img_w.to_f/img_h.to_f
		if ratio < 1
			#$report << "\n\t  Size: #{img_w}x#{img_h} -> #{img_h}x#{img_h}"
			x = img_h/2-img_w/2
			cat = cat.extent(img_h,img_h,x=-x,y=0)
		elsif ratio > 1
			#$report << "\n\t  Size: #{img_w}x#{img_h} -> #{img_w}x#{img_w}"
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


if __FILE__ == $0

options = Parser.parse(ARGV)
#puts options.to_h
Image_Chopper.new(options)

end
