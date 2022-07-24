function varargout = basicActiveSensorEditorGUI(varargin)
% BASICACTIVESENSOREDITORGUI MATLAB code for basicActiveSensorEditorGUI.fig
%      BASICACTIVESENSOREDITORGUI, by itself, creates a new BASICACTIVESENSOREDITORGUI or raises the existing
%      singleton*.
%
%      H = BASICACTIVESENSOREDITORGUI returns the handle to a new BASICACTIVESENSOREDITORGUI or the handle to
%      the existing singleton*.
%
%      BASICACTIVESENSOREDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICACTIVESENSOREDITORGUI.M with the given input arguments.
%
%      BASICACTIVESENSOREDITORGUI('Property','Value',...) creates a new BASICACTIVESENSOREDITORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basicActiveSensorEditorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basicActiveSensorEditorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basicActiveSensorEditorGUI

% Last Modified by GUIDE v2.5 08-Jul-2018 18:52:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @basicActiveSensorEditorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @basicActiveSensorEditorGUI_OutputFcn, ...
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


% --- Executes just before basicActiveSensorEditorGUI is made visible.
function basicActiveSensorEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to basicActiveSensorEditorGUI (see VARARGIN)

    % Choose default command line output for basicActiveSensorEditorGUI
    handles.output = hObject;

    sensor = varargin{1};
    setappdata(hObject,'sensor',sensor);
    
    %set up GUI
    handles = setupGUI(sensor, handles);

    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes basicActiveSensorEditorGUI wait for user response (see UIRESUME)
% uiwait(handles.basicActiveSensorEditorGUI);


function handles = setupGUI(sensor, handles)
    %Set Up Scroll Bars   
    [t, fH] = createDecimalSlider(handles.sensorRangeSlider.Parent, 1E-3, handles.sensorRangeSlider.Position, 0.0, NNS_BasicActiveSensor.maxAllowableMaxRange, sensor.maxRng, NNS_BasicActiveSensor.maxAllowableMaxRange/5, NNS_BasicActiveSensor.maxAllowableMaxRange/20);
    delete(handles.sensorRangeSlider);
    handles.sensorRangeSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) sensorRangeSlider_Callback(hSrc,eventData,handles,fH);

    [t, fH] = createDecimalSlider(handles.maxConeAngleSlider.Parent, 1E-3, handles.maxConeAngleSlider.Position, 0.0, rad2deg(NNS_BasicActiveSensor.maxAllowableMaxConeAngle), rad2deg(sensor.maxConeAngle), 30, 5);
    delete(handles.maxConeAngleSlider);
    handles.maxConeAngleSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) maxConeAngleSlider_Callback(hSrc,eventData,handles,fH);

    [t, fH] = createDecimalSlider(handles.maxRangeErrSlider.Parent, 1E-3, handles.maxRangeErrSlider.Position, 0.0, 100*NNS_BasicActiveSensor.maxAllowableThreeSigRngDevPercent, 100*sensor.threeSigRngDevPercent, 20*NNS_BasicActiveSensor.maxAllowableThreeSigRngDevPercent, 5*NNS_BasicActiveSensor.maxAllowableThreeSigRngDevPercent);
    delete(handles.maxRangeErrSlider);
    handles.maxRangeErrSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) maxRangeErrSlider_Callback(hSrc,eventData,handles,fH);

    [t, fH] = createDecimalSlider(handles.maxAngErrSlider.Parent, 1E-3, handles.maxAngErrSlider.Position, 0.0, 100*NNS_BasicActiveSensor.maxAllowableThreeSigAngDevPercent, 100*sensor.threeSigAngDevPercent, 20*NNS_BasicActiveSensor.maxAllowableThreeSigAngDevPercent, 5*NNS_BasicActiveSensor.maxAllowableThreeSigAngDevPercent);
    delete(handles.maxAngErrSlider);
    handles.maxAngErrSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) maxAngErrSlider_Callback(hSrc,eventData,handles,fH);

    
% --- Outputs from this function are returned to the command line.
function varargout = basicActiveSensorEditorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sensorRangeSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to sensorRangeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    sensor = getappdata(handles.basicActiveSensorEditorGUI,'sensor');
    cb(hObject,eventdata);
    sensor.maxRng = handles.sensorRangeSlider.UserData;

% --- Executes during object creation, after setting all properties.
function sensorRangeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensorRangeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function maxConeAngleSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to maxConeAngleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    sensor = getappdata(handles.basicActiveSensorEditorGUI,'sensor');
    cb(hObject,eventdata);
    sensor.maxConeAngle = deg2rad(handles.maxConeAngleSlider.UserData);

% --- Executes during object creation, after setting all properties.
function maxConeAngleSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxConeAngleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function maxAngErrSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to maxAngErrSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    sensor = getappdata(handles.basicActiveSensorEditorGUI,'sensor');
    cb(hObject,eventdata);
    sensor.threeSigAngDevPercent = handles.maxAngErrSlider.UserData/100;

% --- Executes during object creation, after setting all properties.
function maxAngErrSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAngErrSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function maxRangeErrSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to maxRangeErrSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    sensor = getappdata(handles.basicActiveSensorEditorGUI,'sensor');
    cb(hObject,eventdata);
    sensor.threeSigRngDevPercent = handles.maxRangeErrSlider.UserData/100;

% --- Executes during object creation, after setting all properties.
function maxRangeErrSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxRangeErrSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
