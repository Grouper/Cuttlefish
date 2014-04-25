## Generates a solution
training_data = read.csv("training_data.csv")
test_data = read.csv("test_data.csv")

form1 = members_became_friends ~ m_facebook_friends_count + 
  I(m_facebook_friends_count^2) + 
  I(m_facebook_friends_count^3) + 
  I(m_facebook_friends_count^4) + 
  I(m_facebook_friends_count^5) + 
  f_shoe_size. + 
  I(f_shoe_size.^2) + 
  m_age + I(m_age^2) + 
  I(m_age^3) + 
  I(m_age^4) + 
  I(m_age^5) + 
  I(m_weekly_workouts.) + 
  I(m_weekly_workouts.^2) + 
  I(m_weekly_workouts.^3)

form2 = members_became_friends ~ m_shoe_size. + 
  f_facebook_friends_count + 
  m_facebook_photos_count + 
  f_height + 
  I(f_height^2) + 
  I(f_height^3) + 
  f_age + 
  I(f_age^2) + 
  I(f_age^3) + 
  m_number_of_siblings. + 
  I(m_number_of_siblings.^2) + 
  I(m_number_of_siblings.^3) + 
  m_number_of_pets. + 
  I(m_number_of_pets.^2) + 
  I(m_number_of_pets.^3) + 
  m_height + 
  I(m_height^2) + 
  I(m_height^3)

form3 = members_became_friends ~ 
  m_platinum_albums. + 
  f_pokemon_collected. + 
  I(m_platinum_albums.*f_pokemon_collected.) + 
  I(f_pokemon_collected.*f_facebook_photos_count) + 
  f_weekly_workouts. + 
  f_facebook_photos_count + 
  I(f_weekly_workouts.*f_facebook_photos_count) + 
  f_platinum_albums. + 
  I(f_platinum_albums.^2)

model1 = glm(form1, training_data, family = "binomial")
model2 = glm(form2, training_data, family = "binomial")
model3 = glm(form3, training_data, family = "binomial") 

preds1 = predict(model1, test_data, type = "response")
preds2 = predict(model2, test_data, type = "response")
preds3 = predict(model3, test_data, type = "response")

meta_preds = preds1 + preds2 + preds3


test_data$members_became_friends = meta_preds > 1.5

write.csv(test_data, file = "test_data.csv")


