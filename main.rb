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

# Arguments for data conversion / normalization
nn_args = {
	:conv_cols => [0,11,22],
	:norm_cols => ((0..22).to_a - [0,11,22]),
	:min_range => 0,
	:max_range => 1
}

puts "\n[Loading > Parsing > Normalizing data sets.]"

testing_set  = CsvIO.load_data(csv[:testing])

headers, training_nn = CsvIO.load_data(csv[:training], nn_args)
headers,  testing_nn = CsvIO.load_data(csv[:testing],  nn_args)

puts "Data has been loaded!\n\n"

##############
# Algorithms #
##############

# ID3 Decision Tree

id3 = {
	:training => csv[:training],
	:testing  => testing_set
}

decision_tree	= DecisionTree.new(id3)
decision_tree.solve

# Neural Network Backward Propagation

nn = {
	:headers  => headers,
	:training => training_nn,
	:testing  => testing_nn,
	:in 			=> (headers.size - 1),
	:out 			=> 1
}

neural_net = NeuralNetwork.new(nn)
neural_net.solve

binding.pry

puts "Algorithms has been processed!\n\n"

#####################
# Write Out Results #
#####################

# CsvIO.write_data

# puts "Data has been written!\n\n"