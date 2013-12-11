from sklearn.ensemble import RandomForestClassifier
from sklearn.naive_bayes import GaussianNB
import numpy as np 
import os

# TRUE => 1
# FALSE => 2
# female => -1
# male => 1
os.system("sh clean.sh")

SEX_OFFSET = 11
tf_dict = {
	1 : "TRUE",
	2 : "FALSE"
}

def add_diff_col(matrix, cols):
	col1, col2 = cols
	diff = matrix[:, col1] - matrix[:, col2]
	signs = np.sign(diff)
	diff = np.square(diff)
	diff = np.multiply(signs, diff)
	np.append(matrix, np.matrix(diff).T, axis=1)
	return matrix

def make_submission(clf, name):
	print 'Training %s...' % clf.__class__
	clf.fit(data, labels)
	predictions = clf.predict(test_data)

	# get input from testing set
	lines = []
	with open('test_data.csv', 'r') as f:
		lines = f.readlines()
	header = lines.pop(0) # remove header line
	assert len(lines) == len(predictions)

	# write the predictions to disk
	with open('submission_test_%s.csv' % name, 'w') as wf:
		i = 0
		wf.write(header) # add header back in
		for line in lines:
			wf.write("%s%s\n" % (line.strip(), tf_dict[predictions[i]]))
			i += 1

# load data
training = np.genfromtxt("training_data.csv", delimiter=",",skip_header=1)
testing = np.genfromtxt("test_data.csv", delimiter=",",skip_header=1)

# split into training and testing
n, d = training.shape
d -= 1
data = training[:, 0:d]
labels = training[:, d]

nt, dt = testing.shape
dt -= 1
test_data = testing[:, 0:dt]

print "Shape of training: %d,%d" % data.shape
print "Shape of testing: %d,%d" % test_data.shape

# diff the columns
for i in range(1, 11, 1):
	data = add_diff_col(data, (i, i + SEX_OFFSET))
	test_data = add_diff_col(test_data, (i, i + SEX_OFFSET))

# make classifiers
random_forest = RandomForestClassifier(n_estimators=10000, max_depth=3, n_jobs=3, criterion='gini')
gnb = GaussianNB()

# make submissions and write to disk
make_submission(random_forest, "rforest")
make_submission(gnb, "gnb")