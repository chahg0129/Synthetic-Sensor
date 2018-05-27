%% Real Time Computing
clear all
clc
delete(instrfindall);
Arduino=serial('COM3', 'Baudrate', 115200); % 아두이노 시리얼 통신
fopen(Arduino);


n=100; % environmental avg, std 측정 개수
idx =  1;
X=ones(1,31);
y=ones(1,1);
%%% environment adjustment
for i=1:n
    data(i,1:32) = fscanf(Arduino, '%lf');
    
    idx=idx+1;
    
   
end
data=data(:,1:31); %environmental data의 평균과 표준편차 computation
[m, s] = backgroundModel_class(data,idx,n)

while(1)   
    %%% input data
    current(1, 1:32) = fscanf(Arduino, '%lf');
    y=[y; current(1, 32)];
    current=current(:,1:31);
    
    data = [data; current];
    %%% data processing
    
    current = 1 ./ s .* (current - m);
    
    X = [X; current];
    
    if idx==n+1
        X=X(2:end,:);
        y=y(2:end,1);
    end
    idx=idx+1;
    %%% X에서 y 분리
    save("-mat","3_tissue_new2.mat","X", "y"); %% save("파일형식","저장할이름","저장할변수");
    
end 

