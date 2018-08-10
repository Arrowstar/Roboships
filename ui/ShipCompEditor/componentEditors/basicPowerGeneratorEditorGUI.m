function varargout = basicPowerGeneratorEditorGUI(varargin)
% BASICPOWERGENERATOREDITORGUI MATLAB code for basicPowerGeneratorEditorGUI.fig
%      BASICPOWERGENERATOREDITORGUI, by itself, creates a new BASICPOWERGENERATOREDITORGUI or raises the existing
%      singleton*.
%
%      H = BASICPOWERGENERATOREDITORGUI returns the handle to a new BASICPOWERGENERATOREDITORGUI or the handle to
%      the existing singleton*.
%
%      BASICPOWERGENERATOREDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICPOWERGENERATOREDITORGUI.M with the given input arguments.
%
%      BASICPOWERGENERATOREDITORGUI('Property','Value',...) creates a new BASICPOWERGENERATOREDITORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basicPowerGeneratorEditorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basicPowerGeneratorEditorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basicPowerGeneratorEditorGUI

% Last Modified by GUIDE v2.5 08-Jul-2018 16:25:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @basicPowerGeneratorEditorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @basicPowerGeneratorEditorGUI_OutputFcn, ...
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


% --- Executes just before basicPowerGeneratorEditorGUI is made visible.
function basicPowerGeneratorEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to basicPowerGeneratorEditorGUI (see VARARGIN)

    % Choose default command line output for basicPowerGeneratorEditorGUI
    handles.output = hObject;

    powerGen = varargin{1};
    setappdata(hObject,'powerGen',powerGen);

    %set up GUI
    handles = setupGUI(powerGen, handles);

    % Update handles structure
    guidata(hObject, handles);

%     UIWAIT makes basicPowerGeneratorEditorGUI wait for user response (see UIRESUME)
%     uiwait(handles.basicPowerGeneratorEditorGUI);

function handles = setupGUI(powerGen, handles)
    %Set Up Scroll Bars   
    [t, fH] = createDecimalSlider(handles.powerGenSlider.Parent, 1E-3, handles.powerGenSlider.Position, 0.0, NNS_BasicPowerGenerator.maximumAllowedMaxPowerGen, powerGen.maxPowerGen, NNS_BasicPowerGenerator.maximumAllowedMaxPowerGen/5, NNS_BasicPowerGenerator.maximumAllowedMaxPowerGen/20);
    delete(handles.powerGenSlider);
    handles.powerGenSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) powerGenSlider_Callback(hSrc,eventData,handles, fH);



% --- Outputs from this function are returned to the command line.
function varargout = basicPowerGeneratorEditorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on slider movement.
function powerGenSlider_Callback(hObject, eventdata, handles, cb)
% hObject    handle to powerGenSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    powerGen = getappdata(handles.basicPowerGeneratorEditorGUI,'powerGen');
    cb(hObject,eventdata);
    powerGen.maxPowerGen = handles.powerGenSlider.UserData;

% --- Executes during object creation, after setting all properties.
function powerGenSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to powerGenSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
