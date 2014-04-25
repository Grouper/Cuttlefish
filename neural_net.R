## neural network model
library(nnet)

full_data = read.csv("training_data.csv")
full_data$members_became_friends = factor(full_data$members_became_friends)

test_indexes = sample(1:nrow(training_data), 500)
training_data = full_data[-test_indexes,]
test_data = full_data[test_indexes,]


factors = c("f_age", "m_age", "f_height", "m_height", "f_shoe_size.", "m_shoe_size.",
            "f_number_of_pets.", "m_number_of_pets.", "f_platinum_albums.", "m_platinum_albums.",
            "f_weekly_workouts.", "m_weekly_workouts.", "f_number_of_siblings.", "m_number_of_siblings.",
            "f_pokemon_collected.", "m_pokemon_collected.", "f_facebook_friends_count", "m_facebook_friends_count",
            "f_facebook_photos_count", "m_facebook_photos_count")

string_factors = paste(factors, collapse = " + ")
form = as.formula(paste("members_became_friends", string_factors, sep = " ~ "))

form = members_became_friends ~
  f_number_of_pets. + I(f_number_of_pets.^2) +
  m_number_of_pets. + I(m_number_of_pets.^2) +
  f_platinum_albums. + I(f_platinum_albums.^2) +
  m_platinum_albums. + I(m_platinum_albums.^2) +
  f_weekly_workouts. + I(f_weekly_workouts.^2) +
  m_weekly_workouts. + I(m_weekly_workouts.^2) + 
  f_pokemon_collected. + I(f_pokemon_collected.^2) +
  m_pokemon_collected. + I(m_pokemon_collected.^2)

test_data$members_became_friends = factor(test_data$members_became_friends)
net_model = nnet(form, data = training_data, size = 20)
p = predict(net_model, test_data, type = "class")
sum(p == test_data$members_became_friends)/500
## not too accurate, 53%