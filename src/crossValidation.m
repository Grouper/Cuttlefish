function [trainingIndices, testingIndices] = crossValidation(data_size)
CROSS_VAL_SIZE = 2500;
rp = randperm(data_size);
trainingIndices = rp(1:CROSS_VAL_SIZE);
testingIndices = setdiff(1:data_size,trainingIndices);