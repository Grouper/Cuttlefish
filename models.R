##models
training_data = read.csv("training_data.csv")
subset_indexes = sample(1:nrow(training_data), 1000)
train = training_data[-subset_indexes,]
test = training_data[subset_indexes[1:500],]
confirm = training_data[subset_indexes[501:1000],]

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

model1 = glm(form1, data = train, family = "binomial") 
pred1 = predict(model1, newdata = test, type = "response")

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

model2 = glm(form2, data = train, family = "binomial") 
pred2 = predict(model2, newdata = test, type = "response")

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

model3 = glm(form3, train, family = "binomial")
pred3 = predict(model3, test, type = "response")

newdat = data.frame(mbf = test$members_became_friends, prob1 = (pred1 > .5), prob2 = pred2 > .5, prob3 = pred3 > .5)
meta_model = glm(mbf ~ prob1 + prob2 + prob3, data = newdat, family = "binomial")
meta_preds = rowSums(newdat[,2:4]) > 1
confirm$prob1 = predict(model1, confirm, type = "response") > .5
confirm$prob2 = predict(model2, confirm, type = "response") > .5
confirm$prob3 = predict(model3, confirm, type = "response") > .5
meta_preds = predict(meta_model, newdata = confirm, type = "response")
result = sum((meta_preds > .5) == confirm$members_became_friends)/500




pred1_correct = data.frame(prob = pred1, correct = (pred2 > .5) == test$members_became_friends)
pred2_correct = data.frame(prob =pred2, correct = (pred2 > .5) == test$members_became_friends)
predictions = rbind(pred1_correct, pred2_correct)
qplot(x = pred1, y = pred2)
ggplot(pred2_correct, aes(x=prob, fill = correct)) + geom_histogram( color = "black")

sum( (pred1>.5) == test$members_became_friends)/length(pred1)
sum( (pred2>.5) == test$members_became_friends)/length(pred2)
sum( (pred3>.5) == test$members_became_friends)/length(pred3)
meta_pred = pred1 + pred2 + pred3
sum( (meta_pred > 1.5)== test$members_became_friends)/length(meta_pred)