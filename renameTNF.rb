
# This goes through a folder of images
# in The North Face's style names and renames
# them in RPro's style.
#
# You'll need to create a CSV with three
# columns: pf_id,desc,attr,color
# pf_id is the 16-character RPro item code
# desc is TNF's 4-char item and 3-char color code
# attr is our color code (for mapping)
# color is the actual color style name

require 'csv'

$csv_file = "C:/Documents and Settings/pos/desktop/converttable.csv"

#$img_dir = "R:/RETAIL/IMAGES/4Web"
$img_dir = "C:/Documents and Settings/pos/My Documents/Downloads/WebAssets"

Dir.chdir($img_dir)
$replace = { " " => "_", "/" => "_","-" => "_" }
$converter = Hash.new

def build_converter(csv_data)
	csv_data.each do |row|
		# Fix color name
		if !row[:color].nil?
			color = row[:color].downcase.gsub(/[\/ -]/,$replace)
		else
			color = ""
		end
		desc = row[:desc].gsub("-","_")
		pf_id = row[:pf_id]
		$converter["#{desc}"] = { :pf_id => "#{pf_id}", :color => "#{color}" }
	end
end

def main
	no=0
	# Build the converter
	csv_data = CSV.read($csv_file, :headers=>true,:skip_blanks=>true,:header_converters=>:symbol)
	build_converter(csv_data)

	files = Dir.glob("*jpg")
	files.each do |file|
		no+=1
		if !file.match(/^[A-Z]{16}[_\.]{1}/)
			code = file.match(/^.{8}/)
			this_converter = $converter["#{code}"]
			if this_converter
				newname = "#{this_converter[:pf_id]}"
				if this_converter[:color].length > 1
					newname << "_#{this_converter[:color]}"
				end
				newname << ".jpg"
				File.rename(file,newname)
			else
				puts "Can't rename #{file}"
			end
		end
	end
	return nil
end


#main