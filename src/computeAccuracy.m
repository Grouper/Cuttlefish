function [acc] = computeAccuracy(y_hat,y)
acc = length(find(y_hat==y))/length(y);