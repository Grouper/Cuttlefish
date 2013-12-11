require 'csv'

module CsvIO
	extend self

	def prepare_data
		load_data
		normalize
	end

	def write_data
		puts "Data is being written to CSV!"
	end

	private

	def load_data
		puts "Data is being loaded!"
	end

	def normalize
		puts "Data is being normalized!"
	end

end