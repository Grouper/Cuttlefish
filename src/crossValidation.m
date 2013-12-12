CROSS_VAL_SIZE = 3000;
rp = randperm(size(training_data,1));
trainingIndices = rp(1:CROSS_VAL_SIZE);
testingIndices = setdiff(1:size(training_data),trainingIndices);