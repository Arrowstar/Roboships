function varargout = basicHullEngineRudderEditorGUI(varargin)
% BASICHULLENGINERUDDEREDITORGUI MATLAB code for basicHullEngineRudderEditorGUI.fig
%      BASICHULLENGINERUDDEREDITORGUI, by itself, creates a new BASICHULLENGINERUDDEREDITORGUI or raises the existing
%      singleton*.
%
%      H = BASICHULLENGINERUDDEREDITORGUI returns the handle to a new BASICHULLENGINERUDDEREDITORGUI or the handle to
%      the existing singleton*.
%
%      BASICHULLENGINERUDDEREDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICHULLENGINERUDDEREDITORGUI.M with the given input arguments.
%
%      BASICHULLENGINERUDDEREDITORGUI('Property','Value',...) creates a new BASICHULLENGINERUDDEREDITORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basicHullEngineRudderEditorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basicHullEngineRudderEditorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basicHullEngineRudderEditorGUI

% Last Modified by GUIDE v2.5 09-Jul-2018 20:16:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @basicHullEngineRudderEditorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @basicHullEngineRudderEditorGUI_OutputFcn, ...
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


% --- Executes just before basicHullEngineRudderEditorGUI is made visible.
function basicHullEngineRudderEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to basicHullEngineRudderEditorGUI (see VARARGIN)

    % Choose default command line output for basicHullEngineRudderEditorGUI
    handles.output = hObject;

    ship = varargin{1};
    setappdata(hObject,'ship',ship);

    %set up GUI
    handles = setupGUI(ship, handles);

    % Update handles structure
    guidata(hObject, handles);

%     UIWAIT makes basicHullEngineRudderEditorGUI wait for user response (see UIRESUME)
%     uiwait(handles.basicHullEngineRudderEditorGUI);


function handles = setupGUI(ship, handles)
    hull = ship.hull;
    engine = ship.components.engComps(1);
    rudder = ship.components.rudComps(1);

    %Set Up Scroll Bars   
    [t, fH] = createDecimalSlider(handles.thrustSlider.Parent, 1E-3, handles.thrustSlider.Position, 0.0, NNS_BasicEngine.maximumAllowedMaxThrust, engine.maxThrust, NNS_BasicEngine.maximumAllowedMaxThrust/5, NNS_BasicEngine.maximumAllowedMaxThrust/20);
    delete(handles.thrustSlider);
    handles.thrustSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) thrustSlider_Callback(hSrc,eventData,handles,fH);

	[t, fH] = createDecimalSlider(handles.torqueSlider.Parent, 1E-3, handles.torqueSlider.Position, 0.0, NNS_BasicRudder.maximumAllowedMaxTorque, rudder.maxTorque, NNS_BasicRudder.maximumAllowedMaxTorque/5, NNS_BasicRudder.maximumAllowedMaxTorque/20);
    delete(handles.torqueSlider);
    handles.torqueSlider = t;  
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) torqueSlider_Callback(hSrc,eventData,handles,fH);
    
    [t, fH] = createDecimalSlider(handles.thicknessSlider.Parent, 1E-6, handles.thicknessSlider.Position, NNS_BasicShipHull.minHullThickness, NNS_BasicShipHull.maxHullThickness, hull.hullThickness, NNS_BasicShipHull.maxHullThickness/5, NNS_BasicShipHull.maxHullThickness/20);
    delete(handles.thicknessSlider);
    handles.thicknessSlider = t;  
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) thicknessSlider_Callback(hSrc,eventData,handles,fH);
    
    
% --- Outputs from this function are returned to the command line.
function varargout = basicHullEngineRudderEditorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on slider movement.
function thrustSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to thrustSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    ship = getappdata(handles.basicHullEngineRudderEditorGUI,'ship');
    engine = ship.components.engComps(1);
    cb(hObject,eventdata);
    engine.maxThrust = handles.thrustSlider.UserData;
    

% --- Executes during object creation, after setting all properties.
function thrustSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrustSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function torqueSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to torqueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    ship = getappdata(handles.basicHullEngineRudderEditorGUI,'ship');
    rudder = ship.components.rudComps(1);
    cb(hObject,eventdata);
    rudder.maxTorque = handles.torqueSlider.UserData;

% --- Executes during object creation, after setting all properties.
function torqueSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to torqueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function thicknessSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to thicknessSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    ship = getappdata(handles.basicHullEngineRudderEditorGUI,'ship');
    hull = ship.hull;
    cb(hObject,eventdata);
    hull.hullThickness = handles.thicknessSlider.UserData;

% --- Executes during object creation, after setting all properties.
function thicknessSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thicknessSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
