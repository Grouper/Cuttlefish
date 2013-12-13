load('data/training_data.mat');
load('data/test_data.mat');
[trainingIndices, testingIndices] = crossValidation(size(training_data, 1));
training_data = training_data(:,[1:10]);
train_data = training_data(trainingIndices,:);
dev_data = training_data(testingIndices, :);
train_labels = training_labels(trainingIndices, :);
dev_labels = training_labels(testingIndices, :);

for i=1:size(train_data, 1)
    
end

% options = statset('MaxIter', 500000);
% svm = svmtrain(train_data, train_labels, 'kernel_function', 'linear', 'rbf_sigma', 10, 'options', options);
% results = svmclassify(svm, dev_data);

tree = TreeBagger(50, train_data, train_labels);
results = predict(tree, dev_data)
results = str2double(results)

accuracy = computeAccuracy(results, dev_labels)

