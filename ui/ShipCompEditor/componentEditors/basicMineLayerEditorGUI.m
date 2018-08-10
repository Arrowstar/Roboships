function varargout = basicMineLayerEditorGUI(varargin)
% BASICMINELAYEREDITORGUI MATLAB code for basicMineLayerEditorGUI.fig
%      BASICMINELAYEREDITORGUI, by itself, creates a new BASICMINELAYEREDITORGUI or raises the existing
%      singleton*.
%
%      H = BASICMINELAYEREDITORGUI returns the handle to a new BASICMINELAYEREDITORGUI or the handle to
%      the existing singleton*.
%
%      BASICMINELAYEREDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICMINELAYEREDITORGUI.M with the given input arguments.
%
%      BASICMINELAYEREDITORGUI('Property','Value',...) creates a new BASICMINELAYEREDITORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basicMineLayerEditorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basicMineLayerEditorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basicMineLayerEditorGUI

% Last Modified by GUIDE v2.5 03-Aug-2018 21:07:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @basicMineLayerEditorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @basicMineLayerEditorGUI_OutputFcn, ...
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


% --- Executes just before basicMineLayerEditorGUI is made visible.
function basicMineLayerEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to basicMineLayerEditorGUI (see VARARGIN)

    % Choose default command line output for basicMineLayerEditorGUI
    handles.output = hObject;

    mineLayer = varargin{1};
    setappdata(hObject,'mineLayer',mineLayer);
    
    %set up GUI
    handles = setupGUI(mineLayer, handles);

    % Update handles structure
    guidata(hObject, handles);

%     UIWAIT makes basicMineLayerEditorGUI wait for user response (see UIRESUME)
%     uiwait(handles.basicMineLayerEditorGUI);

function handles = setupGUI(mineLayer, handles)
    %Set Up Scroll Bars   
    [t, fH] = createDecimalSlider(handles.baseDamageSlider.Parent, 1E-3, handles.baseDamageSlider.Position, NNS_BasicMineLayer.minBaseDamage, ...
                                  NNS_BasicMineLayer.maxBaseDamage, mineLayer.baseDamage, NNS_BasicMineLayer.maxBaseDamage/5, NNS_BasicMineLayer.maxBaseDamage/20);    
    delete(handles.baseDamageSlider);
    handles.baseDamageSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) baseDamageSlider_Callback(hSrc,eventData,handles,fH);

    
    [t, fH] = createDecimalSlider(handles.reloadTimeSlider.Parent, 1E-3, handles.reloadTimeSlider.Position, NNS_BasicMineLayer.minReloadTime, ...
                                  NNS_BasicMineLayer.maxReloadTime, mineLayer.reloadTime, NNS_BasicMineLayer.maxReloadTime/5, NNS_BasicMineLayer.maxReloadTime/20);  
    delete(handles.reloadTimeSlider);
    handles.reloadTimeSlider = t;
	t.JavaComponent.StateChangedCallback = @(hSrc,eventData) reloadTimeSlider_Callback(hSrc,eventData,handles,fH);

    
% --- Outputs from this function are returned to the command line.
function varargout = basicMineLayerEditorGUI_OutputFcn(hObject, eventdata, handles) 
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
    mineLayer = getappdata(handles.basicMineLayerEditorGUI,'mineLayer');
    cb(hObject,eventdata);
    mineLayer.baseDamage = handles.baseDamageSlider.UserData;

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
    mineLayer = getappdata(handles.basicMineLayerEditorGUI,'mineLayer');
    cb(hObject,eventdata);
    mineLayer.reloadTime = handles.reloadTimeSlider.UserData;

% --- Executes during object creation, after setting all properties.
function reloadTimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reloadTimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
