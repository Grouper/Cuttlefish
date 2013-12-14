#!/usr/bin/env python
# Copyright 2013 (C) Nicholas Pilkington
# @author Nicholas Pilkington <nicholas.pilkington@gmail.com>

import glob, bunch, pickle, time
import numpy as np
from sklearn import cross_validation
from sklearn.grid_search import GridSearchCV
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC, LinearSVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier, GradientBoostingClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.linear_model import SGDClassifier, LogisticRegression, PassiveAggressiveClassifier

def univariate_feature_selector(X, y, percentile=10):
	""" Univariate Feature Selection """
	from sklearn import svm
	from sklearn.feature_selection import SelectPercentile, f_classif
	X_indices = np.arange(X.shape[-1])
	selector = SelectPercentile(f_classif, percentile=10)
	selector.fit(X, y)
	scores = -np.log10(selector.pvalues_)
	scores /= scores.max()
	clf = svm.SVC(kernel='linear')
	clf.fit(X, y)
	svm_weights = (clf.coef_ ** 2).sum(axis=0)
	svm_weights /= svm_weights.max()
	clf_selected = svm.SVC(kernel='linear')
	clf_selected.fit(selector.transform(X), y)
	svm_weights_selected = (clf_selected.coef_ ** 2).sum(axis=0)
	svm_weights_selected /= svm_weights_selected.max()
	return X_indices[selector.get_support()]

def load_data(training_path, testing_path=None):
	""" Load dataset """

	def gender_to_int(g):
		if g.lower() == 'male':
			return 0.0
		else:
			return 1.0

	def bool_to_int(g):
		if g.lower() == 'true':
			return 1.0
		else:
			return 0.0

	converters = {
		0: gender_to_int,
		11: gender_to_int,
		22: bool_to_int,
	}

	data = np.genfromtxt(training_path, skip_header=1, delimiter=',', converters=converters)

	X = data[:, 0:-1]    
	y = data[:, -1]

	Xt = None
	yt = None
	
	if testing_path is not None:
		data = np.genfromtxt(testing_path, skip_header=1, delimiter=',', converters=converters)
		Xt = data[:, 0:-1]
	else:
		X, Xt, y, yt = cross_validation.train_test_split(X, y, test_size=0.20, random_state=0) 
		
	return X, y, Xt, yt

# Use cached parameter settings, if set to True
# This will use the best estimated parameters from parameters/*.p if False
# It will re-estimate parameters for each model and save them in parameter/*/p
USE_CACHE = False

# The test dataset to use, if set to None is will create
# a 20% holdout set from the training data and use that. 
TEST = 'test_data.csv'

# Parameter estimation cross-validation folds
# Slightly elevated bias but low variance c.f. http://www.cs.iastate.edu/~jtian/cs573/Papers/Kohavi-IJCAI-95.pdf
folds = 10

# Voting mean threshold.
threshold = 0.5

# Load the datasets
X, y, Xt, yt  = load_data(training_path='training_data.csv', testing_path=TEST)

# Class ditribution of testing data is same as training so use stratified folds.
kfold = cross_validation.StratifiedKFold (y, n_folds=folds)

# TODO: This will create a biased estimator and should be run per-fold of CV instead.
# TODO: Change classifiers to Pipelines with StandardScalar running first.
standard = StandardScaler().fit(X)
X  = standard.transform(X)
Xt = standard.transform(Xt)

# Perform feature reduction
# _* features are the most imporant, assume they are graph related. 
# idx = univariate_feature_selector(X, y, percentile=20)
# X  = X[:, idx]
# Xt = Xt[:, idx]

# Models, use naive bayes as a base line because it's fast. 
models = bunch.Bunch({
	'naive'    : GaussianNB(),
	'knn'      : KNeighborsClassifier(),
	'logistic' : LogisticRegression(),
	'pasagg'   : PassiveAggressiveClassifier(),	
	'logreg'   : LogisticRegression(),
	'sgd'      : SGDClassifier(),
	'lsvc'     : LinearSVC(),
	'dtc'      : DecisionTreeClassifier(),
	'ada'      : AdaBoostClassifier(),
	'gbc'      : GradientBoostingClassifier(),
	'randf'    : RandomForestClassifier(),
	'svc'      : SVC(),
})

# Parameters grids for estimation.
parameters = bunch.Bunch({
	'knn' : {
		'n_neighbors' : [25, 100, 200, 500], 
		# 'weights'     : ['uniform', 'distance'],
		'algorithm'   : ['auto'],
		'leaf_size'   : [2, 10, 30],
		#'p'           : [1, 2],
	},
	'logistic' : {

	},
	'pasagg' : {
		'C' : np.logspace(-20, 20, 10), 
		'n_iter' : [1, 2, 5, 10, 50],
	},
	'logreg' : {
		'penalty' : ['l1', 'l2'], 
		'tol' : [0.01, 0.1],
		'C' : np.logspace(-10, 10, 10),
	},
	'sgd' : {
		'penalty' : ['l1', 'l2'], 
		'loss' : ['hinge', 'log'], 
		'alpha' : np.logspace(-10, 10, 10)
	},
	'lsvc' : {
		'C' : np.logspace(-6, 6, 10)
	},
	'dtc' : {
		'max_depth' : [5, 10, 20, 75, 100]
	},
	'ada' : {
		'n_estimators' : [100, 200, 500, 1000, 5000]
	},
	'gbc' : {
		'n_estimators' : [200, 500], 
		'max_depth' : [4], 
		'min_samples_split' : [1], 
		'learning_rate' : [0.01], 
		'loss' : ['deviance']
	},
	'randf' : {
		'max_features' : [1, 2, 3, 10], 
		'max_depth' : [3, 7, 15], 
		'n_estimators' : [100, 100, 10000]                        	
	},
	'svc' : {
		'kernel' : ['rbf', 'sigmoid'], 
		'gamma' : np.logspace(-6, 6, 10), 
		'C' : np.logspace(-6, 6, 10),
	},
	'naive' : {
	},

})


# Classifier pipeline
classifiers = [
	('naive', 	 GridSearchCV(cv=kfold, estimator=models.naive,    param_grid=parameters.naive,    n_jobs=-1)),
	('knn', 	 GridSearchCV(cv=kfold, estimator=models.knn,      param_grid=parameters.knn,      n_jobs=-1)),
 	('logistic', GridSearchCV(cv=kfold, estimator=models.logistic, param_grid=parameters.logistic, n_jobs=-1)),
	('pasagg',   GridSearchCV(cv=kfold, estimator=models.pasagg,   param_grid=parameters.pasagg,   n_jobs=-1)),
	('logreg',   GridSearchCV(cv=kfold, estimator=models.logreg,   param_grid=parameters.logreg,   n_jobs=-1)),
	('sgd',      GridSearchCV(cv=kfold, estimator=models.sgd,      param_grid=parameters.sgd,      n_jobs=-1)),
	('lsvc',     GridSearchCV(cv=kfold, estimator=models.lsvc,     param_grid=parameters.lsvc,     n_jobs=-1)),
	('dtc',      GridSearchCV(cv=kfold, estimator=models.dtc,      param_grid=parameters.dtc,      n_jobs=-1)),
	('ada',      GridSearchCV(cv=kfold, estimator=models.ada,      param_grid=parameters.ada,      n_jobs=-1)),
	('gbc',      GridSearchCV(cv=kfold, estimator=models.gbc,      param_grid=parameters.gbc,      n_jobs=-1)),
	('randf',    GridSearchCV(cv=kfold, estimator=models.randf,    param_grid=parameters.randf,    n_jobs=-1)),
	('svc',      GridSearchCV(cv=kfold, estimator=models.svc,      param_grid=parameters.svc,      n_jobs=-1)),
]

# Train and evaluate classifiers.
test_scores = []
for name, clf in classifiers:
	
	if USE_CACHE:
		with open('parameters/{name}.p'.format(name=name), mode='rb') as fd:
			params = pickle.load(fd)
			est = clf.estimator			
			est.set_params(**params)
			time_start = time.time()
			est.fit(X, y)
			time_end = time.time()
	else:
		time_start = time.time()
	 	clf.fit(X, y)
	 	time_end = time.time()
		est = clf.best_estimator_
		parameters = est.get_params()
		#print parameters
		pickle.dump(parameters, open('parameters/{name}.p'.format(name=name), mode='wb'))
	
	scores = cross_validation.cross_val_score(est, X, y, cv=folds)
	print "model: {name}\ttime: {time:2.2f}  mean: {mean:.2f} +/- {std:.2f}.".format(name=name, time=int(time_end-time_start), mean=np.mean(scores), std=scores.std())
	test_scores.append(scores)
	predictions = est.predict(Xt)
	if TEST is None:
		print "test acc", est.score(Xt, yt)
	pickle.dump(predictions, open('predictions/{name}.p'.format(name=name), mode='wb'))

# Check model stability with pairwise Wilcoxon tests
# Not much unbiased performance difference between models to a voting ensemble should reduce variance.
# import scipy.stats
# for i in xrange(len(test_scores)):
#	for j in xrange(i+1, len(test_scores)):
#		print classifiers[i][0], "vs", classifiers[j][0], scipy.stats.wilcoxon(test_scores[i], test_scores[j])

# Check model stability over IQR.
# import pylab
# baseline_median = 0.56 # Naive bayes
# pylab.figure()
# pylab.plot([0, len(classifiers)+1], [baseline_median, baseline_median], ':k')
# pylab.boxplot(test_scores)
# names = [(i+1, clf[0]) for i, clf in enumerate(classifiers)]
# pylab.xticks(*zip(*names))
# pylab.title('Models on Cuttlefish')
# pylab.xlabel('Model')
# pylab.ylabel('Accuracy')
# pylab.show()


# Perform majority voting on predictions to reduce variance.
stack = None
for pfile in glob.glob('predictions/*.p'):
	with open(pfile, mode='rb') as fd:
		predictions = pickle.load(fd)
		if stack is None:
			stack = predictions
		else:
			stack = np.vstack((stack, predictions))

if len(stack.shape) > 1:
	predictions = stack.mean(axis=0)
else:
	predictions = stack

# Write predictions to file.
dist = [0, 0]
with open('predictions.csv', mode='w') as fd:
	for p in predictions:
		if p >= threshold:
			fd.write('TRUE\n')
			dist[1] += 1
		else:
			fd.write('FALSE\n')
			dist[0] += 1

# Sanity check that prediction distibution is close to training distribution.
print dist
	