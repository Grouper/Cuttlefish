require 'csv'

module CsvIO
	extend self

	def load_data(csv_file, n_args=nil)
		data_set = read_from_csv(csv_file)
		return data_set unless n_args

		headers  = data_set.shift
		data_set = normalize(data_set, n_args)

		return headers, data_set
	end

	def write_data(file, results)
		CSV.open(file,'wb') do |csvfile|
  		results.each { |r| csvfile << r }
  	end
	end

	private

	def read_from_csv(csv_file)
		CSV.read(csv_file.to_s)	  
	end

	def normalize(data_set, n_args)
		convs = n_args[:conv_cols]
		norms = n_args[:norm_cols]

		data_set.transpose.each_with_index.collect do |row, i|
			if convs.include?(i)
				convert(row, n_args)
			else
				row = row.collect(&:to_f)
				norms.include?(i) ? normalize_row(row, n_args) : row
			end
		end.transpose
	end

	def convert(row, n_args)
		mal_val = n_args[:max_range].to_f
		fem_val = n_args[:min_range].to_f

		row.collect do |s|
			case s
			when "male", "female"
				s == "male" ? mal_val : fem_val
			when "TRUE", "FALSE"
				s == "TRUE" ? 1.0 : 0.0
			else
				"FALSE"
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