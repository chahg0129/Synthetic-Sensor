function varargout = GUI_FILTER(varargin)
% GUI_FILTER M-file for GUI_FILTER.fig
%      GUI_FILTER, by itself, creates a new GUI_FILTER or raises the existing
%      singleton*.
%
%      H = GUI_FILTER returns the handle to a new GUI_FILTER or the handle to
%      the existing singleton*.
%
%      GUI_FILTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FILTER.M with the given input arguments.
%
%      GUI_FILTER('Property','Value',...) creates a new GUI_FILTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_FILTER_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_FILTER_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help GUI_FILTER

% Last Modified by GUIDE v2.5 08-May-2018 02:03:24

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_FILTER_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_FILTER_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_FILTER is made visible.
function GUI_FILTER_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);

load('mytrain.mat');
load('params.mat'); %Theta1 Theta2 Theta3

delete(instrfindall);
Arduino=serial('COM3', 'Baudrate', 115200);
fopen(Arduino);


set(handles.accX, 'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor','none','Color',[0 0 0] );
set(handles.accY, 'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor','none','Color',[0 0 0] );
set(handles.accZ, 'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor','none','Color',[0 0 0] );
set(handles.sound, 'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor',[0 0 0],'Color',[0 0 0] );
set(handles.temp, 'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor','none','Color',[0 0 0] );
set(handles.humid, 'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor','none','Color',[0 0 0] );
set(handles.light, 'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor','none','Color',[0 0 0] );

stopTime = '05/02 21:40';
%timeInterval = 0.005;

%% environment adjustment
n=50; % moving avg, std °¹¼ö
idx =  1;
X1=ones(1,31);
y1=ones(1,1);

for i=1:n
    data1(i,1:31) = fscanf(Arduino, '%lf');
    idx=idx+1;
end
[m, s] = backgroundModel_class(data1,idx,n);

%% Collect data
count = 1;
time = now;
r=18167;
x=ones(1,31);
k=1;
mL=0;

while ~isequal(datestr(now,'mm/DD HH:MM'),stopTime)
    k=k+1;  
    if k==25,
        fclose(Arduino);
        delete(instrfindall);
        Arduino=serial('COM3', 'Baudrate', 115200);
        fopen(Arduino);        
        k=0;
    end
   
    data(1,1:31) = fscanf(Arduino, '%lf');
    data = 1 ./ s .* (data - m);
    X(r,:) = data;
    aft_X= zscore(X);
    x(count,:)= aft_X(r,:);
    time(count) = count-1;
    
    axes(handles.sound);
    hold on;
    plot(time, x(:,5), 'Marker','.','LineWidth',1,'Color',[1 1 1]);
    axes(handles.sound);
    hold on;
    plot(time, x(:,5), 'Marker','.','LineWidth',1,'Color',[1 1 1]);  
    axes(handles.accX);
    hold on;
    plot(time, x(:,13), 'Marker','.','LineWidth',1,'Color',[1 0 0]);
    axes(handles.accY);
    hold on;
    plot(time, x(:,14), 'Marker','.','LineWidth',1,'Color',[0 0 1]);
    axes(handles.accZ);
    hold on;
    plot(time, x(:,15), 'Marker','.','LineWidth',1,'Color',[0 1 0]);
    axes(handles.light);
    hold on;
    plot(time, x(:,8), 'Marker','.','LineWidth',1,'Color',[1 1 1]);
    axes(handles.humid);
    hold on;
    plot(time, x(:,2), 'Marker','.','LineWidth',1,'Color',[1 1 1]);
    axes(handles.temp);
    hold on;
    plot(time, x(:,4), 'Marker','.','LineWidth',1,'Color',[1 1 1]);
        
    result = predict(Theta1, Theta2, Theta3, x(count,:));
 
    switch result
        case 1
            set(handles.predict,'String','No event', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
        case 2
            set(handles.predict,'String','Phone ring', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
        case 3
            set(handles.predict,'String','Tissue', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
        case 4
            set(handles.predict,'String','Door close', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
        case 5
            set(handles.predict,'String','Vacuum run', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
        case 6
            set(handles.predict,'String','Faucet run', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
            mL=mL+60;
            set(handles.faucet,'String',sprintf('%d mL',mL), 'FontSize', 30);
        case 7
            set(handles.predict,'String','Light on', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
        case 8
            set(handles.predict,'String','Light off', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
        case 9
            set(handles.predict,'String','Stove on', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
        case 10
            set(handles.predict,'String','Phone ring', 'FontSize', 30);
            set(handles.predict2,'String','Light on', 'FontSize', 30);
        case 11
            set(handles.predict,'String','Phone ring', 'FontSize', 30);
            set(handles.predict2,'String','Light off', 'FontSize', 30);
        case 12
            set(handles.predict,'String','Phone ring', 'FontSize', 30);
            set(handles.predict2,'String','Stove on', 'FontSize', 30);
        case 13
            set(handles.predict,'String','Stove on', 'FontSize', 30);
            set(handles.predict2,'String','Light on', 'FontSize', 30);
        case 14
            set(handles.predict,'String','Stove on', 'FontSize', 30);
            set(handles.predict2,'String','Light off', 'FontSize', 30);
        case 15
            set(handles.predict,'String','Vacuum run', 'FontSize', 30);
            set(handles.predict2,'String','Light on', 'FontSize', 30);
        case 16
            set(handles.predict,'String','Vacuum run', 'FontSize', 30);
            set(handles.predict2,'String','Light off', 'FontSize', 30);
        case 17
            set(handles.predict,'String','Vacuum run', 'FontSize', 30);
            set(handles.predict2,'String','Stove on', 'FontSize', 30);
        otherwise
            set(handles.predict,'String',' ', 'FontSize', 30);
            set(handles.predict2,'String',' ', 'FontSize', 30);
    end
       
    count = count +1;
    
end

fclose(Arduino);
delete(instrfindall);
clear Arduino;




% --- Outputs from this function are returned to the command line.
function varargout = GUI_FILTER_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
