require_relative 'learner'

class DecisionTree < Learner
	def initialize(args)
		super

		# Initialize algorithm specific items.
		@algorithm = "D3 Object"
	end

	def predict
		puts "DecisionTree overrides predict."
		# Compute & write into last column of test.
	end
	
end