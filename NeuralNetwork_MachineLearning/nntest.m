load('pred_trial.mat')
load('y_trial.mat')
acc = sum(pred == testY) ./ numel(testY)    %# accuracy
C = confusionmat(testY, pred)    

%���� ���� sum(total(:,32)==17)