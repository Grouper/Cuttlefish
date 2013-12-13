import pandas as pd
import numpy as np
import sys
import re
import itertools
import operator
from sklearn import linear_model, cross_validation, preprocessing, svm
from sklearn.ensemble import RandomForestClassifier
from sklearn.grid_search import GridSearchCV

#read in the datasets
print "Reading in the data..."
data = pd.read_csv("training_data.cleaned.csv", sep=',')
data_test = pd.read_csv("test_data.cleaned.csv", sep=',')
#get rid of stars in column names just to make things simpler in the code
data.columns=map(lambda x: x.replace('*', ''), data.columns)
data_test.columns=map(lambda x: x.replace('*', ''), data_test.columns)

print "Transforming the data..."
#make string and integer versions of the boolean target variable
data['became_friends_target_str']=map(lambda x: str(x), data['members_became_friends'])
data['became_friends_target_int']=map(lambda x: int(x), data['members_became_friends'])

#construct some varialbes to hold the sign of the male/female difference in matching quantities
sign_variables = ['age', 'height', 'shoe_size', 'number_of_pets', 'weekly_workouts', 'number_of_siblings', 'facebook_friends_count', 'facebook_photos_count']
for sign_variable in sign_variables:
    data[sign_variable+'_diff_sign'] = pd.Categorical.from_array(map(lambda x: int(x), (data['m_'+sign_variable]-data['f_'+sign_variable])>0))
    data_test[sign_variable+'_diff_sign'] = pd.Categorical.from_array(map(lambda x: int(x), (data_test['m_'+sign_variable]-data_test['f_'+sign_variable])>0))

#filter out the target variables and some irrelevant varaibles from the ones that we're going to use to do the fit
varsToFilter = ['f_gender', 'm_gender', 'members_became_friends', 'became_friends_target_str', 'became_friends_target_int']
fitVars=filter(lambda x: x not in varsToFilter, data.columns)

#construct the numpy matrices for the fits
X=np.array(data[fitVars])
X_test=np.array(data_test[fitVars])
Y=np.array(data['became_friends_target_int'])

#scale the continuous variables but not the categorical
varsNotToScale=filter(lambda x: True if re.search("sign", str(x))!=None else False, data.columns)
X_1=np.array(data[filter(lambda x: x not in varsNotToScale, fitVars)])
X_2=np.array(data[varsNotToScale])
#create a scaler so that we can scale the test set with the same parameters
scaler = preprocessing.StandardScaler().fit(X_1)
X_1_scaled=scaler.transform(X_1) 
X_scaled=np.column_stack((X_1_scaled, X_2))

#do the same for the test set
X_test_1=np.array(data_test[filter(lambda x: x not in varsNotToScale, fitVars)])
X_test_2=np.array(data_test[varsNotToScale])
X_test_1_scaled=scaler.transform(X_test_1) 
X_test_scaled=np.column_stack((X_test_1_scaled, X_test_2))

print "Fitting the model..."
#make our random forest classifier and train the best model using all of the data
rf=RandomForestClassifier(n_estimators=150, compute_importances=True, criterion="gini", max_features=None)
rf.fit(X_scaled, Y)

print "Predicting..."
#predict on the test set
test_preds=rf.predict(X_test_scaled)

print "Writing results..."
data_test_original = pd.read_csv("test_data.cleaned.csv", sep=',')
data_test_original['members_became_friends']=map(lambda x: bool(x), test_preds)
data_test_original.to_csv("test_data_withpreds.csv")
