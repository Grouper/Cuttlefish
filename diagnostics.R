## Diagnostics
training_data = read.csv("training_data.csv")

factors = c("f_age", "m_age", "f_height", "m_height", "f_shoe_size.", "m_shoe_size.",
            "f_number_of_pets.", "m_number_of_pets.", "f_platinum_albums.", "m_platinum_albums.",
            "f_weekly_workouts.", "m_weekly_workouts.", "f_number_of_siblings.", "m_number_of_siblings.",
            "f_pokemon_collected.", "m_pokemon_collected.", "f_facebook_friends_count", "m_facebook_friends_count",
            "f_facebook_photos_count", "m_facebook_photos_count")

full_formula = function(factor, power) {
  string = "members_became_friends ~ "
  string = paste(string, factor, sep = "", collapes ="")
  if(power <= 1) {
    return(as.formula(string))
  }
  for(d in 2:power) {
    string = paste(string, " + I(", factor, "^", d, ")", sep= "", collapse = "")
  }
  return(as.formula(string))
}

## finding high bais or high variance
## for each factor
d_curves = matrix(nrow = 5*length(factors), ncol = 4)
d_curves = as.data.frame(d_curves)
colnames(d_curves) = c("factor", "d", "train_error", "test_error")
subset_indexes = sample(1:nrow(training_data), 500)
train = training_data[-subset_indexes,]
test = training_data[subset_indexes,]
index = 1
for(d in 1:5) {
  for(factor in factors) {
    form = full_formula(factor, d)
    logit_model = glm(form, data = train, family = "binomial")
    predict_train = predict(logit_model, train, type = "response") 
    predict_test = predict(logit_model, test, type = "response") 
    exp_err_train = (sum(predict_train[predict_train<.5]) + sum(1-predict_train[predict_train>.5]))/length(predict_train)
    exp_err_test = (sum(predict_test[predict_test<.5]) + sum(1-predict_test[predict_test>.5]))/length(predict_test)
    train_error = sum((predict_train > .5) != train$members_became_friends)/nrow(train)
    test_error = sum((predict_test>.5) != test$members_became_friends)/nrow(test)
    train_error = train_error - exp_err_train
    test_error = test_error - exp_err_test
    d_curves[index,] = c(factor, d, train_error, test_error)
    index = index + 1
  }
}
d_curves$d = as.numeric(d_curves$d)
d_curves$train_error = as.numeric(d_curves$train_error)
d_curves$test_error = as.numeric(d_curves$test_error)
d_curves_melted = melt(d_curves, id = c("factor", "d"))
best_powers = ddply(d_curves, .(factor), function(df) {
  w = which.min(abs(df$test_error))[1]
  return(data.frame(power=df$d[w], error =df$test_error[w]))
  })

ggplot(d_curves_melted, aes(x = d, y = value, color = variable)) + 
  geom_point() + facet_wrap(~factor, scales = "free")

  ## for a d
  ## run a model
  ## get the train error 
  ## get the test error
}
## learning curve
## for each factor
## errors as a function of number of training instances
## errors: training error and cross-validation error

checks = data.frame()
for(i in 1:10) {
  subset_data = training_data[sample(1:nrow(training_data), 500),]
  for(factor in factors) {
    odds_subset_data = ddply(subset_data, factor, function(df) {
      p = sum(df$members_became_friends)/nrow(df)
      return(log(p/(1-p)))
    })
    colnames(odds_subset_data) = c("value", "log_odds")
    odds_subset_data$iter = i
    odds_subset_data$variable = factor
    checks = rbind(checks, odds_subset_data)
  }
}


logit_model = glm(members_became_friends ~ f_age, data = train, family = "binomial")
preds = predict(logit_model, train, type = "response")
cutoffs = data.frame(cutoff =0, acc = 0)
for(i in seq(0, 1, .1)) {
  cl = preds > i
  cutoffs[i*10+1,] = c(i, sum(cl == train$members_became_friends)/nrow(train))
}

logit_model = glm(members_became_friends ~ f_age, data = train, family = "binomial")
preds = predict(logit_model, train, type = "response")
exp_err = (sum(preds[preds<.5]) + sum(1-preds[preds>.5]))/length(preds)
err = sum( (preds > .5) != train$members_became_friends)/nrow(train)

