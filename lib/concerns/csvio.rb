require 'csv'

module CsvIO
	extend self

	def prepare_data(csv_file, n_args)
		headers, data_set	= load_data(csv_file)
						 data_set = normalize(data_set, n_args)

		return headers, data_set
	end

	def write_data
		puts "Data is being written to CSV!"
	end

	private

	def load_data(csv_file)
		data_set = CSV.read("./data/#{csv_file}")
	  headers  = data_set.shift
	  
	  return headers, data_set
	end

	def normalize(data_set, n_args)
		names = n_args[:name_cols]
		norms = n_args[:norm_cols]

		data_set.transpose.each_with_index.collect do |row, i|
			if names.include?(i)
				convert_name(row, n_args)
			else
				row = row.collect(&:to_f)
				norms.include?(i) ? normalize_row(row, n_args) : row
			end
		end.transpose
	end

	def convert_name(row, n_args)
		row.collect do |s|
			if s == "male"
				n_args[:max_range].to_f
			else
				n_args[:min_range].to_f
			end
		end
	end

	def normalize_row(row, n_args)
		min, max 		 = row.min, row.max
		r_min, r_max = n_args[:max_range], n_args[:min_range]
		range 	 		 = r_max - r_min
		
		ratio = range / (max - min)

		row.collect { |x| r_min + (x - min) * ratio }
	end
end