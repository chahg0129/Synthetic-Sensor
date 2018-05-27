%# Fisher Iris dataset

load new_1 % Load training data
[g,a,labels] = unique(y);   %# labels: 1/2/3
data = zscore(X);              %# scale features
numInst = size(data,1);
numLabels = max(labels);

%# split training/testing
idx = randperm(numInst);
numTrain = floor(numInst*0.7); numTest = numInst - numTrain;
trainData = data(idx(1:numTrain),:);  testData = data(idx(numTrain+1:end),:);
trainLabel = labels(idx(1:numTrain)); testLabel = labels(idx(numTrain+1:end));
%# train one-against-all models
model = cell(numLabels,1);
for k=1:numLabels
    model{k} = svmtrain(double(trainLabel==k), trainData, '-c 1 -g 0.2 -b 1'); %cross validation for C and gamma
end

%# get probability estimates of test instances using each model
prob = zeros(numTest,numLabels);
for k=1:numLabels
    [r,b,p] = svmpredict(double(testLabel==k), testData, model{k}, '-b 1');
    prob(:,k) = p(:,model{k}.Label==1);    %# probability of class==k
end

%# predict the class with the highest probability
[e,pred] = max(prob,[],2);
acc = sum(pred == testLabel) ./ numel(testLabel)    %# accuracy
C = confusionmat(testLabel, pred)                   %# confusion matrix