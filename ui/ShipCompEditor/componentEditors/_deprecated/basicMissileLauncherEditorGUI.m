function varargout = basicMissileLauncherEditorGUI(varargin)
% BASICMISSILELAUNCHEREDITORGUI MATLAB code for basicMissileLauncherEditorGUI.fig
%      BASICMISSILELAUNCHEREDITORGUI, by itself, creates a new BASICMISSILELAUNCHEREDITORGUI or raises the existing
%      singleton*.
%
%      H = BASICMISSILELAUNCHEREDITORGUI returns the handle to a new BASICMISSILELAUNCHEREDITORGUI or the handle to
%      the existing singleton*.
%
%      BASICMISSILELAUNCHEREDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICMISSILELAUNCHEREDITORGUI.M with the given input arguments.
%
%      BASICMISSILELAUNCHEREDITORGUI('Property','Value',...) creates a new BASICMISSILELAUNCHEREDITORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basicMissileLauncherEditorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basicMissileLauncherEditorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basicMissileLauncherEditorGUI

% Last Modified by GUIDE v2.5 04-Aug-2018 19:05:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @basicMissileLauncherEditorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @basicMissileLauncherEditorGUI_OutputFcn, ...
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


% --- Executes just before basicMissileLauncherEditorGUI is made visible.
function basicMissileLauncherEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to basicMissileLauncherEditorGUI (see VARARGIN)

    % Choose default command line output for basicMissileLauncherEditorGUI
    handles.output = hObject;

    missileLauncher = varargin{1};
    setappdata(hObject,'missileLauncher',missileLauncher);
    
    %set up GUI
    handles = setupGUI(missileLauncher, handles);

    % Update handles structure
    guidata(hObject, handles);

%     UIWAIT makes basicMissileLauncherEditorGUI wait for user response (see UIRESUME)
%     uiwait(handles.basicMissileLauncherEditorGUI);

function handles = setupGUI(missileLauncher, handles)
    %Set Up Scroll Bars   
    [t, fH] = createDecimalSlider(handles.baseDamageSlider.Parent, 1E-3, handles.baseDamageSlider.Position, NNS_BasicMissileLauncher.minBaseDamage, ...
                                  NNS_BasicMissileLauncher.maxBaseDamage, missileLauncher.baseDamage, NNS_BasicMissileLauncher.maxBaseDamage/5, NNS_BasicMissileLauncher.maxBaseDamage/20);    
    delete(handles.baseDamageSlider);
    handles.baseDamageSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) baseDamageSlider_Callback(hSrc,eventData,handles,fH);

    
    [t, fH] = createDecimalSlider(handles.reloadTimeSlider.Parent, 1E-3, handles.reloadTimeSlider.Position, NNS_BasicMissileLauncher.minReloadTime, ...
                                  NNS_BasicMissileLauncher.maxReloadTime, missileLauncher.reloadTime, NNS_BasicMissileLauncher.maxReloadTime/5, NNS_BasicMissileLauncher.maxReloadTime/20);  
    delete(handles.reloadTimeSlider);
    handles.reloadTimeSlider = t;
	t.JavaComponent.StateChangedCallback = @(hSrc,eventData) reloadTimeSlider_Callback(hSrc,eventData,handles,fH);

    
% --- Outputs from this function are returned to the command line.
function varargout = basicMissileLauncherEditorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function baseDamageSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to baseDamageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    missileLauncher = getappdata(handles.basicMissileLauncherEditorGUI,'missileLauncher');
    cb(hObject,eventdata);
    missileLauncher.baseDamage = handles.baseDamageSlider.UserData;

% --- Executes during object creation, after setting all properties.
function baseDamageSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseDamageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function reloadTimeSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to reloadTimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    missileLauncher = getappdata(handles.basicMissileLauncherEditorGUI,'missileLauncher');
    cb(hObject,eventdata);
    missileLauncher.reloadTime = handles.reloadTimeSlider.UserData;

% --- Executes during object creation, after setting all properties.
function reloadTimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reloadTimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
