## non parametric model, uses Euclidean distance
training_data = read.csv("training_data.csv")

factors = c("f_age", "m_age", "f_height", "m_height", "f_shoe_size.", "m_shoe_size.",
            "f_number_of_pets.", "m_number_of_pets.", "f_platinum_albums.", "m_platinum_albums.",
            "f_weekly_workouts.", "m_weekly_workouts.", "f_number_of_siblings.", "m_number_of_siblings.",
            "f_pokemon_collected.", "m_pokemon_collected.", "f_facebook_friends_count", "m_facebook_friends_count",
            "f_facebook_photos_count", "m_facebook_photos_count")

indexes = sample(1:nrow(training_data), 500)
mem_data = training_data[-indexes,]
test_data = training_data[indexes,]
predict_euc_dist = function(mem_data, test_data) {
  predictions = vector()
  ## ugly for-loops, but it is late and I am too tired to think
  for(j in 1:nrow(test_data)) {
    distances = vector()
    for(i in 1:nrow(mem_data)) {
      sumsq = 0
      for(factor in factors) {
        stdev = sd(mem_data[[factor]])
        diff = (test_data[[factor]][j] - mem_data[[factor]][i])^2/stdev^2
        sumsq = sumsq + diff
      }
      distances[i] = sumsq
    }
    writeLines(paste(j))
    match = which.min(distances)
    predictions[j] = mem_data[["members_became_friends"]][match]
  }
  return(predictions)
}

## takes forever, up to an hour? Not very accurate either, around 55%.
npm = predict_euc_dist(mem_data, test_data)
sum(npm == test_data[["members_became_friends"]])/500