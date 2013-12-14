pos = 0;
count = 0;
for i=1:size(data,1)
%    if data(i,2)>=0 && data(i,4)>=0
     if data(i,2) + data(i,4)<2
        if sum(data(i,[1,3]))/sum(data(i,[2,4]))~=0.5
            count = count+1;
            pred = sum(data(i,[1,3]))/sum(data(i,[2,4])) >= 0.5;
            if pred==y(i)
                pos = pos +1;
            end
        end
    end
end
pos/count

rp = randperm(length(y));
model = svmtrain(y(rp(1:1350)),data(rp(1:1350),:));
[predicted_label, accuracy, prob_estimates] = svmpredict(y(rp(1351:end)),data(rp(1351:end),:),model);
accuracy(1)

tree = TreeBagger(50, data(rp(1:1350),:), y(rp(1:1350)));
 results = predict(tree, data(rp(1351:end),:))
 results = str2double(results)
 accuracy = computeAccuracy(results, y2(rp(1351:end)))


indices = find(data(:,2)+data(:,4)>1);
data2 = data(indices,:);
y2 = y(indices);
rp = randperm(length(y2));
model = svmtrain(y2(rp(1:450)),data2(rp(1:450),:));
[predicted_label, accuracy, prob_estimates] = svmpredict(y2(rp(451:end)),data2(rp(451:end),:),model);
accuracy(1)

