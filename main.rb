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
tr_data = "training_data.csv"
te_data = "test_data.csv"

# Arguments for data normalization
n_args = {
	:name_cols => [0,11],
	:norm_cols => [1,2,9,10,12,13,20,21],
	:min_range => 5,
	:max_range => 10
}

puts "\n[Loading > Parsing > Normalizing data sets.]"

# Load and prepare data for processing
headers, training_data = CsvIO.prepare_data(tr_data, n_args)
headers, testing_data  = CsvIO.prepare_data(te_data, n_args)

puts "Data has been parsed!\n\n"

##########################
# Instantiate Algorithms #
##########################

# decision_tree	 =  DecisionTree.new({}).solve
# neural_network = NeuralNetwork.new({}).solve

#####################
# Write Out Results #
#####################

# CsvIO.write_data

# puts "Data has been written!\n\n"