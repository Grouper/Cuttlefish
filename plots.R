## Interesting Plots, more of them are scattered throughout scratch.R
## In fact, this became a second scratch
library(ggplot2)
training_data = read.csv("training_data.csv")

## correlations
numeric_columns = as.matrix(training_data[,-c(1, 12, 23)])
cor(numeric_columns)

factors = c("f_shoe_size.", "m_shoe_size.",
            "f_number_of_pets.", "m_number_of_pets.", "f_platinum_albums.", "m_platinum_albums.",
            "f_weekly_workouts.", "m_weekly_workouts.", "f_number_of_siblings.", "m_number_of_siblings.",
            "f_pokemon_collected.", "m_pokemon_collected.")


m_pets_plot = ggplot(training_data, aes(members_became_friends)) + geom_histogram() + facet_grid(.~ m_number_of_pets.)
f_pets_plot = ggplot(training_data, aes(members_became_friends)) + geom_histogram() + facet_grid(.~ f_number_of_pets.)
m_albums_plot = ggplot(training_data, aes(members_became_friends)) + geom_histogram() + facet_grid(.~ m_platinum_albums.)
f_albums_plot = ggplot(training_data, aes(members_became_friends)) + geom_histogram() + facet_grid(.~ f_platinum_albums.)


m_pets_odds = ddply(training_data, .(m_number_of_pets.), function(df) {
  p = sum(df$members_became_friends)/nrow(df)
  return(log(p/(1-p)))
})
## dependence on m_number_of_pets suggests almost an x^3 relationship (on whole training set)
qplot(x = m_number_of_pets., y = V1, data = m_pets_odds, size = 3)

set.seed(291)
## checking if true on subsets
checks = data.frame()
for(i in 1:10) {
  subset_data = training_data[sample(1:nrow(training_data), 500),]
  m_pets_odds_subset = ddply(subset_data, .(m_number_of_pets.), function(df) {
    p = sum(df$members_became_friends)/nrow(df)
    return(log(p/(1-p)))
  })
  m_pets_odds_subset$iter = i
  checks = rbind(checks, m_pets_odds_subset)
}
checks_plot = ggplot(data = checks, aes(x = m_number_of_pets., y = V1)) + geom_point(aes(color = iter), size = 3)
## I bet I could fit a cubic to that


Other variables:
set.seed(99)
checks = data.frame()
for(i in 1:10) {
  subset_data = training_data[sample(1:nrow(training_data), 200),]
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
checks = checks[-which(checks$log_odds == Inf | checks$log_odds == -Inf),]

plots = ggplot(checks, aes(x = value, y = log_odds)) + geom_point() + facet_wrap(~variable, scales = "free") + geom_smooth()
