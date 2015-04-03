#!/ruby200/bin

require "csv"

csv_file = "C:/Documents and Settings/pos/Desktop/Book1.csv"
img_dir = "C:/Documents and Settings/pos/My Documents/Downloads/WebAssets"
img_files = Dir.entries(img_dir)
img_files.reject! { |item| item !~ /\.jpg$/ }

csv_data = CSV.read(csv_file, :headers => true).map { |a| Hash[ (a) ] }

csv_data.uniq! { |s| s["Desc 2"] }



puts img_files
#puts csv_data

=begin
class TnfChangeImgName
	def initialize(csv)
		@csv = csv
	end

	def list_files(dir)
	
	end
	
	def change_file_name(file, name)
	
	end

	csv_list = import(@csv) do
		read_attribute_from_file
	end

end
=end
