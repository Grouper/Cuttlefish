require_relative 'learner'

class NeuralNetwork < Learner
	def initialize(args)
		super
		
		# Initialize algorithm specific items.
		@algorithm = "Neural Network Object"
	end

	def train
		puts "NeuralNetwork overrides train."
	end

	def predict
		puts "NeuralNetwork overrides predict."
		# Compute & write into last column of test.
	end
end