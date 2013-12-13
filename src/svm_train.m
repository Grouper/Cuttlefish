load('../data/training_data.mat');
load('../data/test_data.mat');
load('../data/training_labels.mat');
[trainingIndices, testingIndices] = crossValidation(size(training_data, 1));
%training_data = training_data(:,[1:10]);
train_data = training_data(trainingIndices,:);
dev_data = training_data(testingIndices, :);
train_labels = training_labels(trainingIndices, :);
dev_labels = training_labels(testingIndices, :);

%final_tree = TreeBagger(200, [male_feature, female_feature], train_labels);
%total_trained_values = zeros(size(train_data,1), 100);
%total_dev_values = zeros(size(dev_data,1), 100);

options = statset('MaxIter', 500000);

% Generate all feature pairs
sigmas = [5];
overall_best_acc = 0;
male_feature_indices = randperm(10);
female_feature_indices = randperm(10) + 10;
all_feature_indices = randperm(20);

for k=1:length(sigmas)
    best_accuracy_so_far = 0;
    best_features_train = [];
    best_features_dev = [];
    best_indices = [];
    for i=1:20
        i
        %for j=1:10
            accuracies = zeros(3,1);
            for p=1:5
                [trainingIndices, testingIndices] = crossValidation(size(training_data, 1));
                %training_data = training_data(:,[1:10]);
                train_data = training_data(trainingIndices,:);
                dev_data = training_data(testingIndices, :);
                train_labels = training_labels(trainingIndices, :);
                dev_labels = training_labels(testingIndices, :);
                
                feature = train_data(:, all_feature_indices(i));
                %male_feature = train_data(:, male_feature_indices(i));
                %female_feature = train_data(:, female_feature_indices(j));

                feature_dev = dev_data(:, all_feature_indices(i));
                %male_feature_dev = dev_data(:, male_feature_indices(i));
                %female_feature_dev = dev_data(:, female_feature_indices(j));

                proposal_train = [best_features_train, feature];
                proposal_dev = [best_features_dev, feature_dev];
                
                svm = svmtrain(proposal_train, train_labels, 'kernel_function', 'rbf', 'rbf_sigma', sigmas(k), 'options', options);
                result = svmclassify(svm, proposal_dev);
             
                accuracies(p) = computeAccuracy(result, dev_labels);
                
            end
            mean_accuracy = mean(accuracies);
            if mean_accuracy > best_accuracy_so_far
                   best_indices = [best_indices, all_feature_indices(i)];
                   best_features_train = [best_features_train, feature];
                   best_features_dev = [best_features_dev, feature_dev];
                   best_accuracy_so_far = mean_accuracy;

            end

        %end
    end
    best_indices
    if best_accuracy_so_far > overall_best_acc
        best_sigma = sigmas(k)
        overall_best_acc = best_accuracy_so_far
    end
end

% for i=1:10
%     for j=1:10
%         male_feature = train_data(:, i);
%         female_feature = train_data(:,10 + j);
%         
%     
%         male_feature_dev = dev_data(:, i);
%         female_feature_dev = dev_data(:, 10 + j);
%         
%         %svm = svmtrain([male_feature, female_feature], train_labels, 'kernel_function', 'rbf', 'rbf_sigma', 1, 'options', options);
%         %result = svmclassify(svm, [male_feature_dev, female_feature_dev]);
%         %accuracy = computeAccuracy(result, dev_labels)
%         
%         tree = TreeBagger(1000, [male_feature, female_feature], train_labels);
%         
%         [trained_result, trained_scores] = predict(tree, [male_feature, female_feature]);
%         
%         10*(i-1) + j
%         total_trained_values(:, 10*(i-1) + j) = trained_scores(:,1);
%         
%         [dev_result, dev_scores] = predict(tree, [male_feature_dev, female_feature_dev]);
%         
%         total_dev_values(:, 10*(i-1) + j) = dev_scores(:,1);
%         
%         trained_result = str2double(trained_result);
%         
%         accuracy = computeAccuracy(str2double(dev_result), dev_labels)
%     end
% end
% 
% tree = TreeBagger(1000, total_trained_values, train_labels);
% [dev_result, dev_scores] = predict(tree, total_dev_values);
% accuracy = computeAccuracy(str2double(dev_result), dev_labels)

% svm = svmtrain(total_trained_values, train_labels, 'kernel_function', 'rbf', 'rbf_sigma', 18, 'options', options);
% results = svmclassify(svm, total_dev_values);
% accuracy = computeAccuracy(results, dev_labels)


% sigmas = [10, 17, 18, 18.5, 19, 20, 21, 22, 23];
% for i=1:length(sigmas)
%     accuracies = zeros(10,1);
%     for j=1:10
%         [trainingIndices, testingIndices] = crossValidation(size(training_data, 1));
%         train_data = training_data(trainingIndices,:);
%         dev_data = training_data(testingIndices, :);
%         train_labels = training_labels(trainingIndices, :);
%         dev_labels = training_labels(testingIndices, :);
%         svm = svmtrain(train_data, train_labels, 'kernel_function', 'rbf', 'rbf_sigma', sigmas(i), 'options', options);
%         results = svmclassify(svm, dev_data);
%         accuracies(j) = computeAccuracy(results, dev_labels);
%     end
%     mean(accuracies)
%     std(accuracies)
%     
% end


%tree = TreeBagger(500, train_data, train_labels);
%results = predict(tree, train_data);
%results = str2double(results);



