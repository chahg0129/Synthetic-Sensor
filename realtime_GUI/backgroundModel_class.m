%% Background Model

function [m, s] = backgroundModel_class(X, idx, n)
% Rolling mean
m= mean( X(idx-n:idx-1, :) );

% Rolling std
s= std( X(idx-n:idx-1, :) );
s(find(s==0))=1;


end