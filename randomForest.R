## Random Forest model
library(randomForest)
full_data = read.csv("training_data.csv")

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

rand_forest = randomForest(form, data = training_data, importance = TRUE, proximity = TRUE)
p = predict(rand_forest, test_data, type = "response")
p = p > .5
## usually get around 55-56%, performs similarly to logistic regression
sum(p == test_data$members_became_friends) / 500