require 'ai4r'

class Learner
	attr_accessor :algorithm, :headers, :training, :testing

	def initialize(args)
		@headers 	= args[:headers]	|| "N/A"
		@training	= args[:training] || "N/A"
		@testing	= args[:testing]	|| "N/A"
	end

	def solve
		train
		predict
		puts "Analysis complete for #{self.class}!\n\n"
	end

	private

	def train
		puts "No need to explicitly train for #{self.class}!"
	end

	def predict
		raise "Each subclass should implement its own prediction mechanism!"
	end

end