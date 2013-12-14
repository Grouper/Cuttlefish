require_relative 'learner'

class NeuralNetwork < Learner
	def initialize(args)
		super
		@algorithm = setup_neural_network(args)
	end

	def train
		50.times do
			training.each { |r| algorithm.train(r[0...-1], [r[-1]]) }
		end
		puts "#{self.class} has completed training!"
	end

	def predict
		testing.each do |r|
			val   = algorithm.eval(r[0...-1]).first
			r[-1] = (val > 0.625 ? "TRUE" : "FALSE") 
		end
	end

	private

	def setup_neural_network(args)
		Ai4r::NeuralNetwork::Backpropagation.new([args[:in], args[:out]])
	end
end