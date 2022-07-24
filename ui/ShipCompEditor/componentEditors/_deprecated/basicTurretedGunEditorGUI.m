function varargout = basicTurretedGunEditorGUI(varargin)
% BASICTURRETEDGUNEDITORGUI MATLAB code for basicTurretedGunEditorGUI.fig
%      BASICTURRETEDGUNEDITORGUI, by itself, creates a new BASICTURRETEDGUNEDITORGUI or raises the existing
%      singleton*.
%
%      H = BASICTURRETEDGUNEDITORGUI returns the handle to a new BASICTURRETEDGUNEDITORGUI or the handle to
%      the existing singleton*.
%
%      BASICTURRETEDGUNEDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICTURRETEDGUNEDITORGUI.M with the given input arguments.
%
%      BASICTURRETEDGUNEDITORGUI('Property','Value',...) creates a new BASICTURRETEDGUNEDITORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basicTurretedGunEditorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basicTurretedGunEditorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basicTurretedGunEditorGUI

% Last Modified by GUIDE v2.5 09-Jul-2018 17:43:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @basicTurretedGunEditorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @basicTurretedGunEditorGUI_OutputFcn, ...
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


% --- Executes just before basicTurretedGunEditorGUI is made visible.
function basicTurretedGunEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to basicTurretedGunEditorGUI (see VARARGIN)

    % Choose default command line output for basicTurretedGunEditorGUI
    handles.output = hObject;

    gun = varargin{1};
    setappdata(hObject,'gun',gun);
    
    %set up GUI
    handles = setupGUI(gun, handles);

    % Update handles structure
    guidata(hObject, handles);

%     UIWAIT makes basicTurretedGunEditorGUI wait for user response (see UIRESUME)
%     uiwait(handles.basicTurretedGunEditorGUI);

function handles = setupGUI(gun, handles)
    %Set Up Scroll Bars   
    [t, fH] = createDecimalSlider(handles.muzzleVelSlider.Parent, 1E-3, handles.muzzleVelSlider.Position, NNS_BasicTurretedGun.minMuzzleVelocity, ...
                                  NNS_BasicTurretedGun.maxMuzzleVelocity, gun.roundSpeed, NNS_BasicTurretedGun.maxMuzzleVelocity/5, NNS_BasicTurretedGun.maxMuzzleVelocity/20);
    delete(handles.muzzleVelSlider);
    handles.muzzleVelSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) muzzleVelSlider_Callback(hSrc,eventData,handles,fH);


    [t, fH] = createDecimalSlider(handles.baseDamageSlider.Parent, 1E-3, handles.baseDamageSlider.Position, NNS_BasicTurretedGun.minBaseDamage, ...
                                  NNS_BasicTurretedGun.maxBaseDamage, gun.baseDamage, NNS_BasicTurretedGun.maxBaseDamage/5, NNS_BasicTurretedGun.maxBaseDamage/20);    
    delete(handles.baseDamageSlider);
    handles.baseDamageSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) baseDamageSlider_Callback(hSrc,eventData,handles,fH);

    
    [t, fH] = createDecimalSlider(handles.reloadTimeSlider.Parent, 1E-3, handles.reloadTimeSlider.Position, NNS_BasicTurretedGun.minReloadTime, ...
                                  NNS_BasicTurretedGun.maxReloadTime, gun.reloadTime, NNS_BasicTurretedGun.maxReloadTime/5, NNS_BasicTurretedGun.maxReloadTime/20);  
    delete(handles.reloadTimeSlider);
    handles.reloadTimeSlider = t;
	t.JavaComponent.StateChangedCallback = @(hSrc,eventData) reloadTimeSlider_Callback(hSrc,eventData,handles,fH);

    
    [t, fH] = createDecimalSlider(handles.maxAngErrorSlider.Parent, 1E-3, handles.maxAngErrorSlider.Position, 0.0, ...
                                  NNS_BasicTurretedGun.maxMaxAngularError, rad2deg(gun.angleError), NNS_BasicTurretedGun.maxMaxAngularError/5, NNS_BasicTurretedGun.maxMaxAngularError/20);  
    delete(handles.maxAngErrorSlider);
    handles.maxAngErrorSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) maxAngErrorSlider_Callback(hSrc,eventData,handles,fH);

    
% --- Outputs from this function are returned to the command line.
function varargout = basicTurretedGunEditorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function muzzleVelSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to muzzleVelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    gun = getappdata(handles.basicTurretedGunEditorGUI,'gun');
    cb(hObject,eventdata);
    gun.roundSpeed = handles.muzzleVelSlider.UserData;

% --- Executes during object creation, after setting all properties.
function muzzleVelSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muzzleVelSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function baseDamageSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to baseDamageSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    gun = getappdata(handles.basicTurretedGunEditorGUI,'gun');
    cb(hObject,eventdata);
    gun.baseDamage = handles.baseDamageSlider.UserData;

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
function maxAngErrorSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to maxAngErrorSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    gun = getappdata(handles.basicTurretedGunEditorGUI,'gun');
    cb(hObject,eventdata);
    gun.angleError = deg2rad(handles.maxAngErrorSlider.UserData);

% --- Executes during object creation, after setting all properties.
function maxAngErrorSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAngErrorSlider (see GCBO)
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
    gun = getappdata(handles.basicTurretedGunEditorGUI,'gun');
    cb(hObject,eventdata);
    gun.reloadTime = handles.reloadTimeSlider.UserData;

% --- Executes during object creation, after setting all properties.
function reloadTimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reloadTimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
