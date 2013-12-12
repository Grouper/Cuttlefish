require 'ai4r'

class Learner
	attr_accessor :algorithm, :headers, :training, :testing

	def initialize(args)
		@headers 	= args[:headers]
		@training	= args[:training]
		@testing	= args[:testing]

		puts "Args initialized in Learner for #{self.class}!"
	end

	def solve
		train
		predict
		puts "Analysis complete for #{self.class}!\n\n"
	end

	private

	def train
		puts "Train this #{self.class} algorithm!"
	end

	def predict
		puts "Predict results for this #{self.class} algorithm!"
	end

end