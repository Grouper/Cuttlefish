require 'csv'
# Read in data

f_name = '/Users/challenaccepted/Cuttlefish/training_data.csv'
data = []
#female,23,65,6,8,7.5,8,7.5,7.5,1392,454,male,23,69,5,8,7.5,8,7,7,970,498,FALSE
cols = "f_gender,f_age,f_height,f_shoe_size*,f_number_of_pets*,f_platinum_albums*,f_weekly_workouts*,f_number_of_siblings*,f_pokemon_collected*,f_facebook_friends_count,f_facebook_photos_count,m_gender,m_age,m_height,m_shoe_size*,m_number_of_pets*,m_platinum_albums*,m_weekly_workouts*,m_number_of_siblings*,m_pokemon_collected*,m_facebook_friends_count,m_facebook_photos_count,members_became_friends".split(",")
col_num = 
File.open(f_name).each(sep="\r") do |row|
	split_up = row.split(",")
	data << Hash[cols.zip(split_up)]
end
# Do some clean-up, and add a few differences
data.each do |datum|
	datum["members_became_friends"] = datum["members_became_friends"].include?("TRUE") ? true : false
  datum.each do |kee, val|
    if kee != "f_gender" && kee != "m_gender" && kee != "members_became_friends"
      datum[kee] = val.to_f
    end
  end
  datum["d_age"]             = datum["m_age"]              - datum["f_age"]
  datum["d_height"]          = datum["m_height"]           - datum["f_height"]
  datum["d_weekly_workouts"] = datum["m_weekly_workouts*"] - datum["f_weekly_workouts*"]
end

# Only keep features with correl coeffs >= 0.025 with members_became_friends
gaussians = ["d_age"] # Didn't really fit but MUST matter
logistics = ["f_height", "d_height", "f_shoe_size*", "m_shoe_size*", "m_number_of_pets*",
  "f_platinum_albums*", "m_platinum_albums*", "d_weekly_workouts*", "f_facebook_friends_count",
  "m_facebook_friends_count", "f_facebook_photos_count", "m_facebook_photos_count"]

# Returns P(feature|yes_or_no)
def determine_gaussian_fit(data, feature, yes_or_no)
  if yes_or_no
    this_data = data.select { |datum| datum["members_became_friends"] }
  else
    this_data = data.select { |datum| !datum["members_became_friends"] }
  end
  values = this_data.map { |d| d[feature] }
  mean = 0
  values.each do |v|
    mean = mean + v.to_f / values.size.to_f
  end
  sig_squared = 0
  values.each do |v|
    sig_squared = sig_squared.to_f + v**2.to_f / values.size
  end
  sigma = Math.sqrt(sig_squared - mean**2)
  return lambda { |x| 1.0 / (Math.sqrt(2 * 3.1415927) * sigma) *
    Math.exp(-(x - mean)**2 / (2 * sigma**2)) }
end

# Calculate P(feature|yes) and P(feature|no)
prob_yes = data.select { |datum|  datum["members_became_friends"] }.size.to_f / data.size
prob_no  = 1.0 - prob_yes
prob_feature_given_yes = {} # feature => P(feature|match)
prob_feature_given_no  = {} # feature => P(feature|no_match)
data.first.keys.each do |feature|
  puts "Trying out #{feature}"
  if gaussians.include?(feature)
    prob_feature_given_yes[feature] = determine_gaussian_fit(data, feature, true)
    prob_feature_given_no[feature]  = determine_gaussian_fit(data, feature, false)
  elsif logistics.include?(feature)
    # TODO: remove Gaussian hack
    prob_feature_given_yes[feature] = determine_gaussian_fit(data, feature, true)
    prob_feature_given_no[feature]  = determine_gaussian_fit(data, feature, false)
  end
end

# Classify each
classification = []
data.each do |datum|
  p_yes = prob_yes
  p_no  = prob_no
  datum.each do |feature, val|
    if prob_feature_given_yes.include?(feature)
      p_yes = p_yes * prob_feature_given_yes[feature].call(val)
      p_no  = p_no  * prob_feature_given_no[feature].call(val)
    end
  end
  classification << (p_yes >= p_no)
end
train_error = 0
classification.each_with_index do |yes_or_no_train, idx|
  if yes_or_no_train != data[idx]["members_became_friends"]
    train_error = train_error + 1.to_f / data.size
  end
end

def find_best_spot(orig_data, feature, reverse)
  data = orig_data.sort { |a, b| a[feature] <=> b[feature] }
  vals = data.map { |datum| datum[feature] }
  yorn = data.map { |datum| datum["members_became_friends"] }
  # Initialize starting at index before 0...
  err_yes = yorn.select { |y| !y }.size # assume everything in front yes
  err_no  = yorn.select { |y|  y }.size # assume everything in front no
  # ...then start moving index until error hits the best
  best_yes_err = err_yes
  best_no_err  = err_no
  best_yes_idx = -1
  best_no_idx = -1
  vals.each_with_index do |val, idx|
    err_yes = err_yes + (yorn[idx] ?  1 : -1)
    err_no  = err_no  + (yorn[idx] ? -1 :  1)
    if err_yes < best_yes_err
      best_yes_idx = idx
      best_yes_err = err_yes
    end
    if err_no < best_no_err
      best_no_idx = idx
      best_no_err = err_no
    end
  end
  puts "No err #{best_no_err} Yes err #{best_yes_err}"
  l = nil
  v = best_no_err < best_yes_err ? vals[best_no_idx] : vals[best_yes_idx]
  if best_no_err < best_yes_err
    puts "Less than #{v}"
    if reverse
      l = lambda { |x| x < v ? ((data.size - best_no_err).to_f  / data.size) : (best_no_err.to_f / data.size) }
    else
      l = lambda { |x| x < v ? (best_no_err.to_f / data.size) : ((data.size - best_no_err).to_f  / data.size) }
    end
  else
    puts "Greater than #{v}"
    if reverse
      l = lambda { |x| x > v ? ((data.size - best_yes_err).to_f / data.size) : (best_yes_err.to_f / data.size) }
    else
      l = lambda { |x| x > v ? (best_yes_err.to_f / data.size) : ((data.size - best_yes_err).to_f / data.size) }
    end
  end
  l
end

# Try something stupid; medians!
prob_feature_given_yes_2 = {}
prob_feature_given_no_2  = {}
data.first.keys.each do |feature|
  puts "Trying out #{feature}"
  if gaussians.include?(feature)
    prob_feature_given_yes_2[feature] = find_best_spot(data, feature, true)
    prob_feature_given_no_2[feature]  = find_best_spot(data, feature, false)
  elsif logistics.include?(feature)
    prob_feature_given_yes_2[feature] = find_best_spot(data, feature, true)
    prob_feature_given_no_2[feature]  = find_best_spot(data, feature, false)
  end
end

# Classify each
classification_2 = []
data.each do |datum|
  p_yes = prob_yes
  p_no  = prob_no
  datum.each do |feature, val|
    if prob_feature_given_yes_2.include?(feature)
      p_yes = p_yes * prob_feature_given_yes_2[feature].call(val)
      p_no  = p_no  * prob_feature_given_no_2[feature].call(val)
    end
  end
  classification_2 << (p_yes >= p_no)
end
train_error_2 = 0
classification_2.each_with_index do |yes_or_no_train, idx|
  if yes_or_no_train != data[idx]["members_became_friends"]
    train_error_2 = train_error_2 + 1.to_f / data.size
  end
end

#
f_name = '/Users/challenaccepted/Cuttlefish/test_data.csv'
data_test = []
#female,23,65,6,8,7.5,8,7.5,7.5,1392,454,male,23,69,5,8,7.5,8,7,7,970,498,FALSE
cols = "f_gender,f_age,f_height,f_shoe_size*,f_number_of_pets*,f_platinum_albums*,f_weekly_workouts*,f_number_of_siblings*,f_pokemon_collected*,f_facebook_friends_count,f_facebook_photos_count,m_gender,m_age,m_height,m_shoe_size*,m_number_of_pets*,m_platinum_albums*,m_weekly_workouts*,m_number_of_siblings*,m_pokemon_collected*,m_facebook_friends_count,m_facebook_photos_count,members_became_friends".split(",")
col_num = 
File.open(f_name).each(sep="\r") do |row|
  split_up = row.split(",")
  data_test << Hash[cols.zip(split_up)]
end
# Do some clean-up, and add a few differences
data_test.each do |datum|
  datum.each do |kee, val|
    if kee != "f_gender" && kee != "m_gender" && kee != "members_became_friends"
      datum[kee] = val.to_f
    end
  end
  datum["d_age"]             = datum["m_age"]              - datum["f_age"]
  datum["d_height"]          = datum["m_height"]           - datum["f_height"]
  datum["d_weekly_workouts"] = datum["m_weekly_workouts*"] - datum["f_weekly_workouts*"]
end
# Classify each test datum
classification_test = []
data_test.each do |datum|
  p_yes = prob_yes
  p_no  = prob_no
  datum.each do |feature, val|
    if prob_feature_given_yes_2.include?(feature)
      p_yes = p_yes * prob_feature_given_yes_2[feature].call(val)
      p_no  = p_no  * prob_feature_given_no_2[feature].call(val)
    end
  end
  classification_test << (p_yes >= p_no)
end
# Write it all out
writer = File.open('/Users/challenaccepted/Cuttlefish/results.csv', 'w')
i = 0
File.open(f_name).each(sep="\r") do |row|
  line = row
  # line = line + (classification_test[i] ? "TRUE" : "FALSE")
  line = line.sub("\r", (classification_test[i] ? "TRUE" : "FALSE") + "\r")
  i = i + 1
  writer.write(line)
  writer.flush
end
writer.close


