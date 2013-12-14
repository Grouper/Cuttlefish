load('../data/training_data.mat');
load('../data/training_labels.mat');
load('../data/test_data.mat');
load svm_test_results.mat;
female_data = training_data(:,1:10);
male_data = training_data(:,11:20);
female_data_test = test_data(:,1:10);
male_data_test = test_data(:,11:20);

count = 0;

for i = 1:size(test_data,1)
    prev_labels_female = [];
    prev_labels_male = [];
    for j = 1:size(training_data,1)
    
        if norm(male_data_test(i,:)-male_data(j,:)) < 0.001
            prev_labels_male = [prev_labels_male training_labels(j)];
        end
        if norm(female_data_test(i,:)-female_data(j,:)) < 0.001
            prev_labels_female = [prev_labels_female training_labels(j)];
        end

        
    end
    if length(prev_labels_female) + length(prev_labels_male) >= 2
        prev_labels_female
        prev_labels_male
        
        majority_vote = (sum(prev_labels_female) + sum(prev_labels_male))/(length(prev_labels_female) + length(prev_labels_male))
        pred = majority_vote > 0.5
        if majority_vote ~= 0.5%leave ties to svm
            count = count + 1;
            test_results(i) = pred;%override by majority voting

        end
    end
% 
%     if length(prev_labels_female) + length(prev_labels_male) == 1
%         prev_labels_female
%         prev_labels_male
%         count
%         majority_vote = (sum(prev_labels_female) + sum(prev_labels_male))/(length(prev_labels_female) + length(prev_labels_male))
%         pred = majority_vote > 0.5
%         if majority_vote ~= 0.5%leave ties to svm
% 
%             count = count + 1;
%             if test_results(i)~=pred
%                pos = pos+1;
%             end
%         end
%     end
end
output = cell(length(test_results),1);
for i = 1:length(output)
    if test_results(i) == 0
        output{i} = 'FALSE';
    else
        output{i} = 'TRUE';
    end
end
save output
