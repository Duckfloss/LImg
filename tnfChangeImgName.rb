#!/ruby200/bin

require 'csv'
require 'yaml'

#settings for mac and windows
settings = YAML::load_file "tnfChangeImgName.yml"
os = settings["os"]
csv_file = settings[os]["csv_file"]
$img_dir = settings[os]["img_dir"]
Dir.chdir($img_dir) #change to the img directory

#get the ".jpg" files in the image directory
img_files = Dir.glob('*.jpg')
#img_files.reject! { |item| item !~ /\.jpg$/ }

#map csv to hashes
#csv_data = CSV.read(csv_file, :headers => true).map { |a| Hash[ (a) ] }
csv_data = []
CSV.foreach(csv_file, :headers => true) do |row|
	hsh = {}
  row.to_hash.each_pair do |k,v|
		csv_data << hsh.merge!({k.downcase => v})
  end
end

#and discard all with duplicate desc 2 fields
csv_data.uniq! { |s| s["desc 2"] }

def rename_file(file, item)
	if item["color"]
		color = "_"+item["color"].downcase #downcase color name
		color.gsub!(/[\ \/]/, '_') #replace spaces and slashes with underscores
		name = "#{item['style sid']}#{color}.jpg"
	else
		name = "#{item['style sid']}.jpg"
	end
	if File.rename($img_dir+file, $img_dir+name)
#		puts name
	else
		puts "Error: #{name}"
	end
end

def rename_test(file, item)
	if item["color"]
		color = "_"+item["color"].downcase #downcase color name
		color.gsub!(/[\ \/]/, '_') #replace spaces and slashes with underscores
		name = "#{item['style sid']}#{color}.jpg"
	else
		name = "#{item['style sid']}.jpg"
	end
	puts "#{file} --> #{name}"
end

csv_data.each do |item|
	style = item["desc 2"]
	if style.length > 4
		style.gsub!(/[\ \-\/\\]/, "_") #replace space, slash, dash with underscore
		file = Dir.glob("*#{style}*")
		if file[0].nil?
			puts "Failure with file #{style}"
		else
			rename_test(file[0], item)
		end
	else
		if file.nil?
			puts "Failure with file #{style}"
		else
			rename_test(file, item)
		end
	end
end
