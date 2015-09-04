
# This goes through a CSV of two columns
# code and color
# compares code to ECI map and adds
# it if necessary


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
		$converter[row[:code].gsub!("-","_")] = { :pf_id => "#{row[:pf_id]}", :color => "#{color}"}
	end
	
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
end



#main