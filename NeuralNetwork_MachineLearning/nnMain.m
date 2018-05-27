clear ; close all; clc

hidden_layer_size_1 = 30;   % 25 hidden units
hidden_layer_size_2 = 25;

%% =========== Part 1: Loading and Visualizing Data =============
fprintf('Loading and Visualizing Data ...\n')

load('trainData.mat');


X=zscore(X);
m=size(X,1);
input_layer_size = size(X,2);
%num_labels=max(y);
num_labels=17;

load('params_1.mat');

fprintf('Program paused. Press enter to continue.\n');



%% split training / testing
idx = randperm(m);
numTrain = floor(m*0.7); 
numTest = m - numTrain;

trainX = X(idx(1:numTrain),:);  
testX = X(idx(numTrain+1:end),:);

trainY = y(idx(1:numTrain)); 
testY = y(idx(numTrain+1:end));



%% ================ Part 2: Initializing Pameters ================

fprintf('\nInitializing Neural Network Parameters ...\n')

%initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size_1);
%initial_Theta2 = randInitializeWeights(hidden_layer_size_1, hidden_layer_size_2);
%initial_Theta3 = randInitializeWeights(hidden_layer_size_2, num_labels);


initial_Theta1=Theta1;
initial_Theta2=Theta2;
initial_Theta3=Theta3;


% Unroll parameters (∫§≈Õ»≠)
initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:); initial_Theta3(:)];



%% ================ Part 3: Compute Cost (Feedforward) ================
%  To the neural network, you should first start by implementing the
%  feedforward part of the neural network that returns the cost only. You
%  should complete the code in nnCostFunction.m to return cost. After
%  implementing the feedforward to compute the cost, you can verify that
%  your implementation is correct by verifying that you get the same cost
%  as us for the fixed debugging parameters.
%
%  We suggest implementing the feedforward cost *without* regularization
%  first so that it will be easier for you to debug. Later, in part 4, you
%  will get to implement the regularized cost.
%
fprintf('\nFeedforward Using Neural Network ...\n')

% Weight regularization parameter (we set this to 0 here).
lambda = 0;

J = nnCostFunction(initial_nn_params, input_layer_size, hidden_layer_size_1, ...
                   hidden_layer_size_2, num_labels, trainX, trainY, lambda);

fprintf(['Cost at parameters (loaded from date: %f '...
         '\n\n\n'], J);






%% =============== Part 4: Implement Regularization ===============
%  Once your cost function implementation is correct, you should now
%  continue to implement the regularization with the cost.
%

fprintf('\nChecking Cost Function (w/ Regularization) ... \n')

% Weight regularization parameter (we set this to 1 here).
lambda = 5;

J = nnCostFunction(initial_nn_params, input_layer_size, hidden_layer_size_1, ...
                   hidden_layer_size_2, num_labels, trainX, trainY, lambda);

fprintf(['Cost at parameters (loaded from data): %f '...
         '\n\n\n'], J);





%% =================== Part 8: Training NN ===================
%  You have now implemented all the code necessary to train a neural 
%  network. To train your neural network, we will now use "fmincg", which
%  is a function which works similarly to "fminunc". Recall that these
%  advanced optimizers are able to train our cost functions efficiently as
%  long as we provide them with the gradient computations.
%
fprintf('\nTraining Neural Network... \n')

%  After you have completed the assignment, change the MaxIter to a larger
%  value to see how more training helps.
options = optimset('MaxIter', 1000);

%  You should also try different values of lambda
lambda = 5;
costFunction = @(p) nnCostFunction(p, ...
                                   input_layer_size, ...
                                   hidden_layer_size_1, ...
                                   hidden_layer_size_2, ...
                                   num_labels, trainX, trainY, lambda);
% Create "short hand" for the cost function to be minimized



% Now, costFunction is a function that takes in only one argument (the
% neural network parameters)


  
                                   
[nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

% Obtain Theta1 and Theta2 back from nn_params
idx1 = hidden_layer_size_1 * (input_layer_size + 1);
Theta1 = reshape(nn_params(1:idx1), ...
                 hidden_layer_size_1, (input_layer_size + 1));
                 
idx2 = hidden_layer_size_2 * (hidden_layer_size_1 + 1);
Theta2 = reshape(nn_params((1 + idx1): idx1 + idx2), ...
                 hidden_layer_size_2, (hidden_layer_size_1 + 1));
                 
Theta3 = reshape(nn_params((1 + idx1 + idx2):end), ...
                 num_labels, (hidden_layer_size_2 + 1));


fprintf('Program paused. Press enter to continue.\n');



%% ================= Part 9: Visualize Weights =================
%  You can now "visualize" what the neural network is learning by 
%  displaying the hidden units to see what features they are capturing in 
%  the data.

%fprintf('\nVisualizing Neural Network... \n')

%displayData(Theta1(:, 2:end));

%fprintf('\nProgram paused. Press enter to continue.\n');
%pause;



%% ================= Part 10: Implement Predict =================
%  After training the neural network, we would like to use it to predict
%  the labels. You will now implement the "predict" function to use the
%  neural network to predict the labels of the training set. This lets
%  you compute the training set accuracy.

pred = predict(Theta1, Theta2, Theta3, testX);


fprintf('\nTest Set Accuracy: %f\n', mean(double(pred == testY)) * 100);

save("-mat","y_trial.mat","testY");
save("-mat","pred_trial.mat","pred");                
save ("-mat","params_trial.mat","Theta1","Theta2","Theta3")
