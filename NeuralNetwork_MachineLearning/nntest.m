load('pred_trial.mat')
load('y_trial.mat')
acc = sum(pred == testY) ./ numel(testY)    %# accuracy
C = confusionmat(testY, pred)    

%°¹¼ö ¼¼±â sum(total(:,32)==17)