
# This goes through a CSV of two columns
# Attr and Color
# compares code to ECI map and adds
# it if necessary


require 'csv'

$csv = "C:/Documents and Settings/pos/desktop/converttable.csv"

$ECImap = "data/ECImap.ini"

def build_converter(csv)
	# Build the converter
	$converter = Hash.new
	csv_data = CSV.read(csv, :headers=>true,:skip_blanks=>true,:header_converters=>:symbol)
	csv_data.each do |row|
		$converter[row[:attr]] = row[:color]
	end
end

def build_map(ini)
	$map = Hash.new
	if File.exist?(ini)
		file = File.open(ini)
		while line = file.gets do
			$map["#{line.match(/(?<=\>).+(?=\=)/)}"] = "#{line.match(/(?<=\=).+/)}"
		end
		file.close if !file.closed?
	end
end


def main
	build_converter($csv)
	build_map($ECImap)
	no=0
	$converter.each do |k,v|
		if !$map[k].nil?
			if $map[k].length < 1 || $map[k] != v
				$map["#{k}"] = v
			end
		else
			$map["#{k}"] = v
		end
	end

	hashout = $map.sort_by{|k,v| k.downcase}
	File.open($ECImap,"w") do |file|
		hashout.each do |k,v|
			file.puts "ATTR<_as_>#{k}=#{v}"
		end
	end


=begin
	files = Dir.entries($img_dir)
	files.each do |file|
		if file=~/\.jpg/
			if !file.match(/\w{16}\_/)
			no+=1
			puts "#{no} > #{file}"
				code = file.match(/.{8}/)
				format = file.match(/_\w{1,3}\.jpg$/)
				this_converter = $converter["#{code}"]
				if this_converter
					newname = "#{this_converter[:pf_id]}_#{this_converter[:color]}#{format}"
					File.rename(file,newname)
				end
			end
		end
	end
=end
end



#main
