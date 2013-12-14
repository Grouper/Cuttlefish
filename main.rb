# Install RubyGems required for program
require 'rubygems'
require 'bundler/setup'
Bundler.require

# Include all concerns and models in ./lib/*/
Dir.glob('./lib/*').each do |folder|
  Dir.glob(folder +'/*.rb').each do |file|
    require file
  end
end

##############
# Parse Data #
##############

# Training data files
csv = {
	:training => "./data/training_data.csv",
	:testing =>  "./data/test_data.csv"
}

# Arguments for data normalization
n_args = {
	:name_cols => [0,11],
	:norm_cols => [1,2,9,10,12,13,20,21],
	:min_range => 5,
	:max_range => 10
}

puts "\n[Loading > Parsing > Normalizing data sets.]"

training_orig = CsvIO.load_data(csv[:training])
testing_orig  = CsvIO.load_data(csv[:testing])

headers, training_norm = CsvIO.load_data(csv[:training], n_args)
headers,  testing_norm = CsvIO.load_data(csv[:testing],  n_args)

puts "Data has been parsed!\n\n"

##########################
# Instantiate Algorithms #
##########################

id3_args = {
	:training => csv[:training],
	:testing  => testing_orig
}

decision_tree	= DecisionTree.new(id3_args)
decision_tree.solve

puts "Algorithms has been processed!\n\n"

#####################
# Write Out Results #
#####################

# CsvIO.write_data

# puts "Data has been written!\n\n"