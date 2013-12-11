import numpy as np 
from sklearn.cross_validation import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, accuracy_score
from sklearn.cross_validation import KFold, cross_val_score
import sklearn.cross_validation

from sklearn.linear_model import SGDClassifier
from sklearn import svm
from sklearn import linear_model
from sklearn import neighbors
from sklearn.naive_bayes import GaussianNB, MultinomialNB, BernoulliNB
from sklearn import tree
from sklearn.ensemble import AdaBoostClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.lda import LDA
from sklearn.qda import QDA

# TRUE => 1
# FALSE => 2
# female => -1
# male => 1

# load data
training = np.genfromtxt("training_data.csv", delimiter=",",skip_header=1)
testing = np.genfromtxt("test_data.csv", delimiter=",",skip_header=1)

# split into training and testing
n, d = training.shape
d -= 1
data = training[:, 0:d]
labels = training[:, d]
data_train, data_test, labels_train, labels_test = train_test_split(data, labels, test_size=0.3)

# some classifiers will complain otherwise
labels_test = np.array(labels_test, dtype=np.uint8)
labels_train = np.array(labels_train, dtype=np.uint8)

def add_diff_col(matrix, cols):
	col1, col2 = cols
	diff = matrix[:, col1] - matrix[:, col2]
	signs = np.sign(diff)
	diff = np.square(diff)
	diff = np.multiply(signs, diff)
	np.append(matrix, np.matrix(diff).T, axis=1)
	return matrix

# diff the columns
offset = 11
for i in range(1, 11, 1):
	data_train = add_diff_col(data_train, (i, i + offset))
	data_test = add_diff_col(data_test, (i, i + offset))

print "Shape of training: %d,%d" % data_train.shape
print "Shape of testing: %d,%d" % data_test.shape

classifiers = [
	GaussianNB(),
	AdaBoostClassifier(n_estimators=100),
	GradientBoostingClassifier(n_estimators=100, learning_rate=0.75, max_depth=1),
	GradientBoostingClassifier(n_estimators=100, learning_rate=0.2, max_depth=2),
	GradientBoostingClassifier(n_estimators=10, learning_rate=0.75, max_depth=1),
	LDA(),
	RandomForestClassifier(n_estimators=10000, max_depth=3, n_jobs=3, criterion='gini'),
]

def try_classifier(clf, train_x, train_y, test_x, test_y):
	clf.fit(train_x, train_y)
	predictions = clf.predict(test_x)
	target_names = ['Friends', 'Not Friends']
	#print(classification_report(labels_test, predictions, target_names=target_names))
	accuracy = accuracy_score(labels_test, predictions)
	cv = KFold(data_train.shape[0], n_folds=10)
	cv_vector = cross_val_score(clf, train_x, train_y, cv=cv)
	avg_cv = np.mean(cv_vector)
	print "Average cross validation score was: %f" % np.mean(cv_vector)
	print "Accuracy was: %f" % accuracy
	print
	return accuracy, avg_cv, clf

results = []
for c in classifiers:
	print "Training %s ..." % c.__class__
	results.append(try_classifier(c, data_train, labels_train, data_test, labels_test))

## great, decided on random forests and maybe GaussianNB
