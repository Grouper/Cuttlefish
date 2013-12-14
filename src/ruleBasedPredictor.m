load('../data/training_data.mat');
load('../data/test_data.mat');
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
%     if length(prev_labels_female)>0 || length(prev_labels_male)>0
    if length(prev_labels_female) + length(prev_labels_male) > 2
        count = count + 1;
        prev_labels_female
        prev_labels_male
    end
end
count