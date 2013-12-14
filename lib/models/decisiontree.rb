require_relative 'learner'

class DecisionTree < Learner
	def initialize(args)
		super
		@algorithm = setup_tree(training)
		@headers   = testing.shift
	end

	def predict
		testing.each { |r| r[-1] = algorithm.eval(r[0...-1]) rescue "FALSE" }
	end

	private

	def setup_tree(training_file)
		data_set = Ai4r::Data::DataSet.new
		tree_set = data_set.load_csv_with_labels(training_file)
		Ai4r::Classifiers::ID3.new.build(tree_set)
	end
end