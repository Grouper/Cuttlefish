import numpy as np 
from sklearn.cross_validation import train_test_split
from sklearn.ensemble import RandomForestClassifier
import os

# clean files
os.system("sh clean.sh")

# TRUE => 1
# FALSE => 2
# female => -1
# male => 1

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
offset = 11
for i in range(1, 11, 1):
	data = add_diff_col(data, (i, i + offset))
	test_data = add_diff_col(test_data, (i, i + offset))

# train random forest
w = 10000
clf = RandomForestClassifier(n_estimators=w, max_depth=3, n_jobs=3, criterion='gini')
clf.fit(data, labels)
predictions = clf.predict(test_data)

# get input from testing set
lines = []
with open('test_data.csv', 'r') as f:
	lines = f.readlines()
lines.pop(-1) # remove empty line
assert len(lines) == len(predictions)

# write the predictions to disk
with open('submission_test.csv', 'w') as wf:
	i = 0
	for line in lines:
		wf.write("%s%s\n" % (line.strip(), tf_dict[predictions[i]]))
		i += 1
