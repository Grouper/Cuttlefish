from sklearn.ensemble import RandomForestClassifier
import csv
import random

def clean_data(data):
	# converts to floats and adds columns for differences
	return [[float(v) for v in row] + [float(row[i])-float(row[i+10]) for i in range(0,10)] for row in data[1:]]

data = []
result = []
with open('training_data.csv', 'rU') as csvfile:
	rowreader = csv.reader(csvfile, delimiter=',')
	for row in rowreader:
		data.append(row[1:11]+row[12:-1])
		result.append(row[-1])

result=[0 if v=='FALSE' else 1 for v in result[1:]]		
data=clean_data(data)

# This is pretty silly, it creates random forests with 3% cross-validation and just looks for the one
# that performs best on the cv data. This data seems to defy most methods.
best_score=0.0
best_model=None
# This takes ages, but you can reduce the number of models it builds to make it faster
for outer in range(500):
	tr_data=[]
	tr_result=[]
	cv_data=[]
	cv_result=[]
	for i in range(0,len(data)):
		if (random.random()<0.03):
			cv_data.append(data[i])
			cv_result.append(result[i])
		else:
			tr_data.append(data[i])
			tr_result.append(result[i])
		
	clf = RandomForestClassifier(n_estimators=random.randint(10,30), 
								criterion="entropy" if random.random()<0.5 else "gini", 
								max_features="auto" if random.random()<0.5 else None);
	clf.fit(tr_data, tr_result)

	match_count=0
	for i in range(0, len(cv_data)):
		if clf.predict(cv_data[i])[0]==cv_result[i]: match_count+=1

	if (float(match_count)/len(cv_data))>best_score:
		best_score=float(match_count)/len(cv_data)
		best_model=clf
		
test=[]
with open('test_data.csv', 'rU') as csvfile:
	rowreader = csv.reader(csvfile, delimiter=',')
	for row in rowreader:
		test.append(row[1:11]+row[12:-1])

header=test[0]
td=clean_data(test)

print ','.join(header)+',members_became_friends'
for i in range(0,len(td)):
	print ','.join(test[i+1])+','+('FALSE' if best_model.predict(td[i])[0]==0 else 'TRUE')