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

puts "\nAll files have been required!\n\n"

##############
# Parse Data #
##############

CsvIO.prepare_data

puts "Data has been parsed!\n\n"

#####################
# Create Algorithms #
#####################

decision_tree	 =  DecisionTree.new({}).solve
neural_network = NeuralNetwork.new({}).solve

#####################
# Write Out Results #
#####################

CsvIO.write_data

puts "Data has been written!\n\n"