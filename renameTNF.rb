
# This goes through a folder of images
# in The North Face's style names and renames
# them in RPro's style.
#
# You'll need to create a CSV with three
# columns: pf_id,attr,color
# pf_id is the 16-character RPro item code
# Attr is TNF's 4-char item and 3-char color code
# Color is the actual color style name

require 'csv'

$csv_file = "C:/Documents and Settings/pos/desktop/converttable.csv"

$img_dir = "R:/RETAIL/IMAGES/4Web"

Dir.chdir($img_dir)
$replace = { " " => "_", "/" => "_","-" => "_" }
$converter = Hash.new

def main
no=0
	# Build the converter
	csv_data = CSV.read($csv_file, :headers=>true,:skip_blanks=>true,:header_converters=>:symbol)
	csv_data.each do |row|
		# Fix color name
		color = row[:color].downcase.gsub(/[\/ -]/,$replace)
		$converter[row[:attr].gsub!("-","_")] = { :pf_id => "#{row[:pf_id]}", :color => "#{color}"}
	end
	
	files = Dir.entries($img_dir)
	files.each do |file|
		if file=~/\.jpg/
			if !file.match(/\w{16}\_/)
			no+=1
			puts "#{no} > #{file}"
				code = file.match(/.{8}/)
				format = file.match(/_\w{1,3}\.jpg$/)
				this_converter = $converter["#{attr}"]
				if this_converter
					newname = "#{this_converter[:pf_id]}_#{this_converter[:color]}#{format}"
					File.rename(file,newname)
				end
			end
		end
	end
end



#main