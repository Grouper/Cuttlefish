options = statset('MaxIter', 500000);
svm = svmtrain(training_data, training_labels, 'kernel_function', 'polynomial', 'options', options);
results = svmclassify(svm, test_data);