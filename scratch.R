training_data = read.csv("training_data.csv")
## in hindsight looking at all these linear factors is pretty naive ("dimensionality reduction"?)
training_data$age_diff = training_data$m_age - training_data$f_age
training_data$height_diff = training_data$m_height - training_data$f_height
training_data$shoe_diff = training_data$m_shoe_size - training_data$f_shoe_size
training_data$pets_diff = training_data$m_number_of_pets - training_data$f_number_of_pets
training_data$albums_diff = training_data$m_platinum_albums - training_data$f_platinum_albums
training_data$workouts_diff = training_data$m_weekly_workouts - training_data$f_weekly_workouts
training_data$siblings_diff = training_data$m_number_of_siblings - training_data$f_number_of_siblings
training_data$pokemon_diff = training_data$m_pokemon_collected - training_data$f_pokemon_collected
training_data$friends_diff = training_data$m_facebook_friends_count - training_data$f_facebook_friends_count
training_data$photos_diff = training_data$m_facebook_photos_count - training_data$f_facebook_photos_count

## additional factors based on manual analysis
training_data$shoe_sum = training_data$m_shoe_size. + training_data$f_shoe_size.
training_data$pets_sum = training_data$m_number_of_pets + training_data$f_number_of_pets
training_data$workouts_diff_squared = training_data$workouts_diff^2
training_data$workouts_sum = training_data$m_weekly_workouts + training_data$f_weekly_workouts
training_data$workouts_sum_squared = training_data$m_weekly_workouts^2 + training_data$f_weekly_workouts^2
training_data$siblings_diff_squared = training_data$siblings_diff^2
training_data$siblings_sum = training_data$m_number_of_siblings + training_data$f_number_of_siblings
training_data$f_pokebums = training_data$f_pokemon_collected + training_data$f_platinum_albums
training_data$f_pokebums_diff = training_data$f_pokemon_collected - training_data$f_platinum_albums
training_data$m_pets_poke_diff = training_data$m_number_of_pets. - training_data$m_pokemon_collected.
training_data$m_pets_poke = training_data$m_number_of_pets. + training_data$m_pokemon_collected.
training_data$m_pets_times_albums = training_data$m_number_of_pets * training_data$m_platinum_albums
training_data$f_pokebum_mult = training_data$f_pokemon_collected. * training_data$f_platinum_albums.

form = members_became_friends ~ 
  height_diff +
  f_age + 
  f_shoe_size. +  
  f_number_of_pets. +
  f_platinum_albums. +
  f_weekly_workouts. +
  f_number_of_siblings. +
  f_facebook_photos_count + 
  m_age +
  m_shoe_size. +
  m_number_of_pets. +
  m_platinum_albums. +
  m_number_of_siblings. +
  m_facebook_friends_count +
  m_facebook_photos_count +
  f_age*m_age +
  f_number_of_pets.*m_number_of_pets. +
  f_platinum_albums.*m_platinum_albums. +
  f_number_of_siblings.*m_number_of_siblings.


## final model
form = members_became_friends ~
 f_facebook_friends_count +
 m_facebook_friends_count +
 height_diff +
 shoe_sum +
 f_age +
 m_facebook_photos_count +
 I(m_number_of_pets. * m_platinum_albums.) +
 m_weekly_workouts. +
 I(m_weekly_workouts.^2) +
 I(m_weekly_workouts.^3) +
 I(m_weekly_workouts.^4) 


 #experiments
form = members_became_friends ~
  m_number_of_siblings. + I(m_number_of_siblings.^2) + I(m_number_of_siblings.^3) + I(m_number_of_siblings.^4)+ I(m_number_of_siblings.^5)
logit_model = glm(form, data = training_data, family = "binomial")

## Evaluate model
cv <- function(form, n) {
  results = vector()
  for(i in 1:n) {
    ## seperate into training set and test set for cross-validation
    subset_indexes = sample(1:nrow(training_data), nrow(training_data) - 500)
    subset = training_data[subset_indexes,]
    test_set = training_data[-subset_indexes,]
  
    ## make the logit model and use it to predict some probabilities
    logit_model = glm(form, data = subset, family = "binomial")
    predictions = predict(logit_model, newdata = test_set, type = "response")
    ## solidify prediction probabilities into actual "predictions"
    predictions = predictions > .5
  
    agrees_with_data = predictions == test_set$members_became_friends
  
    ## store results to test
    results[i] = sum(agrees_with_data)/500
  }
  writeLines(paste(summary(results)))
  return(mean(results))
}


became_friends = subset(training_data, members_became_friends == TRUE)
not_friends = subset(training_data, members_became_friends == FALSE)


## doing some manual analysis

library(ggplot2)
library(reshape)

training_data$m_shoe_factor = factor(training_data$m_shoe_size.)
training_data$f_shoe_factor = factor(training_data$f_shoe_size.)
training_data$numeric_friends = factor(training_data$members_became_friends)
shoe_relations = ddply(training_data, .(m_shoe_factor, f_shoe_factor), function(x) {
  friendship_prob = sum(x$members_became_friends)/nrow(x)
  num_counts = nrow(x)
  return(data.frame(friendship_prob = friendship_prob, num_counts = num_counts))
})



shoe_plot = ggplot(training_data, aes(m_shoe_size., f_shoe_size., color = members_became_friends)) + 
  geom_point(position = "jitter")# + facet_grid(.~members_became_friends)
pets_plot = ggplot(training_data, aes(m_number_of_pets, f_number_of_pets.)) +
   geom_point(position = "jitter") + facet_grid(.~members_became_friends)

## shoe_size seems to increase likelihood of friendship when male + female goes up!
shoe_plot2 = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(f_shoe_size. ~ m_shoe_size.)

height_int_plot = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(f_height~m_height)

## pets doesn't really seem to show anything together most of the information seems to be lost in the categorization
pets_int_plot = ggplot(training_data, aes(members_became_friends)) + geom_histogram() + facet_grid(f_number_of_pets. ~ m_number_of_pets.)
m_pets_plot = ggplot(training_data, aes(members_became_friends)) + geom_histogram() + facet_grid(.~ m_number_of_pets.)
f_pets_plot = ggplot(training_data, aes(members_became_friends)) + geom_histogram() + facet_grid(.~ f_number_of_pets.)

## nothing here (for now), nearly dead 50/50
albums_int_plot = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(f_platinum_albums. ~ m_platinum_albums.)

## I can definitely see some "no"'s here, hard to capture, difference seems to catch it
check_data = training_data[sample(1:nrow(training_data), replace = TRUE, 100),]
workouts_int_plot = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(f_weekly_workouts. ~ m_weekly_workouts.)

## most yes's seem to be clustered in the top middle, not that significant
siblings_int_plot = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(f_number_of_siblings. ~ m_number_of_siblings.)

## can't see anything here
pokemon_int_plot = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(m_pokemon_collected. ~ f_pokemon_collected.)       

## can't see anything still
m_pokemon_albums = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(m_pokemon_collected. ~ m_platinum_albums.)


f_pokemon_albums = ggplot(training_data, aes(members_became_friends)) + geom_histogram() + facet_grid(f_pokemon_collected. ~ f_platinum_albums.)

m_pets_pokemon = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(m_number_of_pets. ~ m_pokemon_collected.)

m_pets_albums = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(m_number_of_pets. ~ m_platinum_albums.)

f_pets_m_albums = ggplot(training_data, aes(numeric_friends)) + geom_histogram() + facet_grid(f_number_of_pets. ~ m_platinum_albums.)

## pets times albums got 3 stars
m_pets_times_albums_plot = ggplot(training_data, aes(numeric_friends)) + geom_histogram()+ facet_grid(.~m_pets_times_albums)

f_pokebum_multplot = ggplot(training_data, aes(numeric_friends)) + geom_histogram()+ facet_grid( .~ f_pokebum_mult)

## time to speed up this process a little bit
factors = c("height_diff", "f_age", "m_age", "f_height", "m_height", "f_shoe_size.", "m_shoe_size.",
            "f_number_of_pets.", "m_number_of_pets.", "f_platinum_albums.", "m_platinum_albums.",
            "f_weekly_workouts.", "m_weekly_workouts.", "f_number_of_siblings.", "m_number_of_siblings.",
            "f_pokemon_collected.", "m_pokemon_collected.", "f_facebook_friends_count", "m_facebook_friends_count",
            "f_facebook_photos_count", "m_facebook_photos_count")

## this factors includes only the factors not determined to be very effective
# factors = c("f_age", "m_age",
#             "f_number_of_pets.",
#             "f_weekly_workouts.", "f_number_of_siblings.", "m_number_of_siblings.",
#             "f_pokemon_collected.", "m_pokemon_collected.", "f_facebook_photos_count")

index = 1
measure_var = "members_became_friends"
predictors = data.frame(variable = "hello", p_value = 1)
for(x in factors) {
  dep_var = x
  string_rep = paste(dep_var, collapse = "*")
  string_rep = paste("I(", string_rep, ")", sep= "", collapse = "")
  formula = as.formula(paste(measure_var, string_rep, sep = " ~ " ))
  logit_model = glm(formula, data = training_data, family = "binomial")
  p_value = summary(logit_model)$coefficients[,1][2]
  predictors[index,] = data.frame(variable = string_rep, p_value = p_value)
  index = index + 1
  for(y in factors) {
    dep_var = c(x, y)
    string_rep = paste(dep_var, collapse = "*")
    string_rep = paste("I(", string_rep, ")", sep= "", collapse = "")
    formula = as.formula(paste(measure_var, string_rep, sep = " ~ " ))
    logit_model = glm(formula, data = training_data, family = "binomial")
    p_value = summary(logit_model)$coefficients[,1][2]
    predictors[index,] = data.frame(variable = string_rep, p_value = p_value)
    index = index + 1
#     for(z in factors) {
#       dep_var = c(x, y, z)
#       string_rep = paste(dep_var, collapse = "*")
#       string_rep = paste("I(", string_rep, ")", sep= "", collapse = "")
#       formula = as.formula(paste(measure_var, string_rep, sep = " ~ " ))
#       logit_model = glm(formula, data = training_data, family = "binomial")
#       p_value = summary(logit_model)$coefficients[,4][2]
#       predictors[index,] = data.frame(variable = string_rep, p_value = p_value)
#       index = index + 1      
#     } 
  }
}
acceptable_p_value = .01/nrow(predictors)
sum(predictor$p_value < acceptable_p_value)
predictors = predictors[order(predictors$p_value, decreasing = TRUE),]
formula = members_became_friends ~ I(m_shoe_size. * f_facebook_friends_count * m_facebook_friends_count)
logit_model = glm(formula, data = training_data, family = "binomial")


factors = c("f_age", "m_age", "f_height", "m_height", "f_shoe_size.", "m_shoe_size.",
            "f_number_of_pets.", "m_number_of_pets.", "f_platinum_albums.", "m_platinum_albums.",
            "f_weekly_workouts.", "m_weekly_workouts.", "f_number_of_siblings.", "m_number_of_siblings.",
            "f_pokemon_collected.", "m_pokemon_collected.", "f_facebook_friends_count", "m_facebook_friends_count",
            "f_facebook_photos_count", "m_facebook_photos_count")

string_factors = paste(factors, collapse = " + ")
form_tree = as.formula(paste("members_became_friends", string_factors, sep = " ~ "))

form_logit = members_became_friends ~
  f_facebook_friends_count +
  m_facebook_friends_count +
  height_diff +
  shoe_sum +
  f_age +
  m_facebook_photos_count +
  I(m_number_of_pets. * m_platinum_albums.) +
  m_weekly_workouts. +
  I(m_weekly_workouts.^2) +
  I(m_weekly_workouts.^3) +
  I(m_weekly_workouts.^4) 

dec_tree = rpart(form, data = training_data)
plot(dec_tree)

training_data$members_became_friends = factor(training_data$members_became_friends)
## Evaluate model
results = vector()
agreement = vector()
for(i in 1:100) {
  ## seperate into training set and test set for cross-validation
  subset_indexes = sample(1:nrow(training_data), nrow(training_data) - 500)
  subset = training_data[subset_indexes,]
  test_set = training_data[-subset_indexes,]
  
  ## make the logit model and use it to predict some probabilities
  dec_tree = rpart(form_tree, data = subset)
  logit_model = glm(form_logit, data = subset, family = "binomial")
  predictions_tree = predict(dec_tree, newdata = test_set, type = "prob")
  predictions_logit = predict(logit_model, newdata = test_set, type = "response")
  ## solidify prediction probabilities into actual "predictions"
  predictions_tree = predictions_tree[,1] < predictions_tree[,2]
  predictions_logit = predictions_logit > .5
  agrees_with_data = predictions_tree == as.logical(test_set$members_became_friends)
  tree_agrees_logit = predictions_tree == predictions_logit
  ## store results to test
  agreement[i] = sum(tree_agrees_logit)/500
  results[i] = sum(agrees_with_data)/500
}
results
summary(results)
agreement
summary(agreement)


form_net = form_tree

net_model = nnet(form_net, data = training_data, size = 5)


## Evaluate model
results = vector()
agreement = vector()
for(i in 1:100) {
  ## seperate into training set and test set for cross-validation
  subset_indexes = sample(1:nrow(training_data), nrow(training_data) - 500)
  subset = training_data[subset_indexes,]
  test_set = training_data[-subset_indexes,]
  
  net_model = nnet(form_net, data = training_data, size = 19, maxiter = 2000)
  logit_model = glm(form_logit, data = subset, family = "binomial")
  predictions_net = as.logical(predict(net_model, newdata = test_set, type = "class"))
  predictions_logit = predict(logit_model, newdata = test_set, type = "response")
  ## solidify prediction probabilities into actual "predictions"
  predictions_logit = predictions_logit > .5
  agrees_with_data = predictions_net == as.logical(test_set$members_became_friends)
  tree_agrees_logit = predictions_net == predictions_logit
  ## store results to test
  agreement[i] = sum(tree_agrees_logit)/500
  results[i] = sum(agrees_with_data)/500
}
results
summary(results)
agreement
summary(agreement)


### simulation of expected results
results = vector()
for(i in 1:500) {
  true_val = sample(c(TRUE, FALSE), 1)
  if(runif(1) < .6) logit_val = true_val else logit_val = !true_val
  if(runif(1) < .6) net_val = true_val else net_val = !true_val
  if(runif(1) < .6) tree_val = true_val else tree_val = !true_val
  if(sum(c(logit_val, net_val, tree_val) == true_val) > 1) results[i] = TRUE else results[i] = FALSE
}
sum(results)/500

## want to make the test error / cross validation error plots

subs = subset(1:nrow(training_data), 500)
train = training_data[-subs,]
test = trainind_data[subs,]
library(gbm)
gmb_model = gbm(form, data = train, distribution= "bernoulli", interaction.depth = 3, cv.folds = 5, train.fraction = .7)
summary(gmb_model)
preds = predict(gmb_model, test, type = "response")


factors = c("f_number_of_pets.", "f_platinum_albums.",
            "f_number_of_siblings.",
            "m_pokemon_collected.", "m_platinum_albums.", "f_pokemon_collected.",
            "f_weekly_workouts.", "f_facebook_photos_count", "f_platinum_albums.")

string_factors = paste(factors, collapse = " + ")
form_tree = as.formula(paste("members_became_friends", string_factors, sep = " ~ "))

effects = data.frame(fac = "f", fac2= "f", effect = 1, stringsAsFactors=F)
index = 1
best = 0
for(fac in factors) {
  for(fac2 in factors) {
    form = as.formula(paste("members_became_friends ~ m_platinum_albums. + f_pokemon_collected. + I(m_platinum_albums.*f_pokemon_collected.) + I(f_pokemon_collected.*f_facebook_photos_count) + f_weekly_workouts. + f_facebook_photos_count + I(f_weekly_workouts.*f_facebook_photos_count) + f_platinum_albums. + I(f_platinum_albums.^2) + ", fac, " + ", fac2, " + I(", fac,"*",fac2, ")", collapse = ""))
    effects[index,1] = fac
    effects[index, 2] = fac2
    effects[index,3] = cv(form, 100) - best
    index = index + 1
  }
}
effects[which.max(effects[,3]), ]

powers = data.frame(d = 1, effect = 1)
index = 1
for(d in 1:10) {
  form= full_formula("m_shoe_size.", d)
  powers[index, 1] = d
  powers[index, 2] = cv(form, 1000)
  index = index + 1
}


form = members_became_friends ~ m_facebook_friends_count + I(m_facebook_friends_count^2) + I(m_facebook_friends_count^3) + I(m_facebook_friends_count^4) + I(m_facebook_friends_count^5) + f_shoe_size. + I(f_shoe_size.^2) + m_age + I(m_age^2) + I(m_age^3) + I(m_age^4) + I(m_age^5) + I(m_weekly_workouts.) + I(m_weekly_workouts.^2) + I(m_weekly_workouts.^3)
cv(form, 100)