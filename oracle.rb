require 'libsvm'
require 'csv'

puts 'Warming up the crystal ball...'

# Where are the files, again?
file = {
  sample: 'training_data.csv',
  test:   'test_data.csv'
}

# Data stores
data = {
  sample: [],
  test:   [],
}

# String to integer coversion
convert = {
  'female' => 0,
  'male' => 1,
  'false' => 0,
  'true' => 1
}

# CSV options
options = { headers:    :first_row,
            converters: [:numeric]
}

# Define problem and parameter for later use
problem = Libsvm::Problem.new
parameter = Libsvm::SvmParameter.new

# Superfluously huge cache
parameter.cache_size = 1024

# Such precision
parameter.eps = 2
parameter.c = 10

# Did the users become friends?
labels = []
count = 0

# Read the training file
puts 'Rolling the dice...'
CSV.open(file[:sample], 'r', options) do |csv|
  csv.each do |row|
    if count < 500
      # Normalize the huge numbers
      row.each do |key, value|
        if value.is_a? Integer
          row[key] = value / 10 if value > 100
        else
          # Convert gender and boolean to integers
          convert.each do |word, number|
            row[key] = number if value.is_a?(String) && value.downcase == word
          end
        end
      end
      # THROW IT ON THE GROUND
      data[:sample].push row.to_hash
      labels.push row.to_hash['members_became_friends']
      count += 1
    end
  end
end

puts 'Asking the gods...'
examples = data[:sample].each.map do |arr|
  Libsvm::Node.features(arr)
end

puts 'Reading the tea leaves...'
problem.set_examples(labels, examples)
model = Libsvm::Model.train(problem, parameter)

puts 'Consulting mother nature...'
CSV.open(file[:test], 'r', options) do |csv|
  csv.each do |row|
    # Normalize the huge numbers
    row.each do |key, value|
      if value.is_a? Integer
        row[key] = value / 10 if value > 100
      else
        # Convert gender and boolean to integers
        convert.each do |word, number|
          row[key] = number if value.is_a?(String) && value.downcase == word
        end
      end
    end
    # THROW IT ON THE GROUND
    data[:test].push row.to_hash
  end
end

count = 1

data[:test].each.map do |arr|
  arr.delete('members_became_friends')
  pred = model.predict(Libsvm::Node.features(arr))
  count += 1
  puts "Line #{count} is true!" if pred == 1
end
