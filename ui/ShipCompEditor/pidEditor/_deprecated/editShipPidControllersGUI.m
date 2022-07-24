function varargout = editShipPidControllersGUI(varargin)
    % EDITSHIPPIDCONTROLLERSGUI MATLAB code for editShipPidControllersGUI.fig
    %      EDITSHIPPIDCONTROLLERSGUI, by itself, creates a new EDITSHIPPIDCONTROLLERSGUI or raises the existing
    %      singleton*.
    %
    %      H = EDITSHIPPIDCONTROLLERSGUI returns the handle to a new EDITSHIPPIDCONTROLLERSGUI or the handle to
    %      the existing singleton*.
    %
    %      EDITSHIPPIDCONTROLLERSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in EDITSHIPPIDCONTROLLERSGUI.M with the given input arguments.
    %
    %      EDITSHIPPIDCONTROLLERSGUI('Property','Value',...) creates a new EDITSHIPPIDCONTROLLERSGUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before editShipPidControllersGUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to editShipPidControllersGUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help editShipPidControllersGUI
    
    % Last Modified by GUIDE v2.5 28-Jul-2018 22:40:21
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @editShipPidControllersGUI_OpeningFcn, ...
        'gui_OutputFcn',  @editShipPidControllersGUI_OutputFcn, ...
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
    
    
    % --- Executes just before editShipPidControllersGUI is made visible.
function editShipPidControllersGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to editShipPidControllersGUI (see VARARGIN)
    
    % Choose default command line output for editShipPidControllersGUI
    handles.output = hObject;
    
    if(numel(varargin) >= 1)
        ship = varargin{1};
    else
        arena = NNS_Arena([-25 25], [-25 25]);
        ship = NNS_Ship.createDefaultBasicShip(arena);
    end
    setappdata(hObject,'ship',ship);
    setappdata(hObject,'okayToRunSimulation',true);
    setappdata(hObject,'sliderResolution',1E-3);
    
    %set up GUI
    handles = setupGUI(handles);
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes editShipPidControllersGUI wait for user response (see UIRESUME)
    % uiwait(handles.editShipPidControllersGUI);
    
function handles = setupGUI(handles)
    pid = getSelPidController(handles);
    sliderResolution = getappdata(handles.editShipPidControllersGUI,'sliderResolution');
    
    %Set Up Scroll Bars
    [t, fH] = createDecimalSlider(handles.kpGainSlider.Parent, sliderResolution, handles.kpGainSlider.Position, 0.0, 100, pid.getPIDParam(NNS_PidController.PID_KP), 10, 2);
    delete(handles.kpGainSlider);
    handles.kpGainSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) kpGainSlider_Callback(hSrc,eventData,handles,fH);
    
    [t, fH] = createDecimalSlider(handles.kpGainSlider.Parent, sliderResolution, handles.kiGainSlider.Position, 0.0, 100, pid.getPIDParam(NNS_PidController.PID_KI), 10, 2);
    delete(handles.kiGainSlider);
    handles.kiGainSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) kiGainSlider_Callback(hSrc,eventData,handles,fH);
    
    [t, fH] = createDecimalSlider(handles.kpGainSlider.Parent, sliderResolution, handles.kdGainSlider.Position, 0.0, 100, pid.getPIDParam(NNS_PidController.PID_KD), 10, 2);
    delete(handles.kdGainSlider);
    handles.kdGainSlider = t;
    t.JavaComponent.StateChangedCallback = @(hSrc,eventData) kdGainSlider_Callback(hSrc,eventData,handles,fH);
    
    pidControllerSelButtonGrp_SelectionChangedFcn(handles.pidControllerSelButtonGrp, [], handles);
    
    
function pidController = getSelPidController(handles)
    ship = getappdata(handles.editShipPidControllersGUI,'ship');
    
    if(handles.pidControllerSelButtonGrp.SelectedObject == handles.speedControllerRadioBtn)
        pidController = ship.basicPropagator.speedCntrlr;
    elseif(handles.pidControllerSelButtonGrp.SelectedObject == handles.headingControllerRadioBtn)
        pidController = ship.basicPropagator.headingCntrlr;
    else
        error('Unknown PID Controller radio button selection.');
    end
    
    % --- Outputs from this function are returned to the command line.
function varargout = editShipPidControllersGUI_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    
    % --- Executes on button press in saveAndCloseButton.
function saveAndCloseButton_Callback(hObject, eventdata, handles)
    % hObject    handle to saveAndCloseButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    close(handles.editShipPidControllersGUI);
    
    % --- Executes on slider movement.
function kpGainSlider_Callback(hObject, eventdata, handles, cb)
    % hObject    handle to kpGainSlider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    pidController = getSelPidController(handles);
    cb(hObject,eventdata);
    okayToRunSimulation = getappdata(handles.editShipPidControllersGUI,'okayToRunSimulation');
    
    if(pidController.getPIDParam(NNS_PidController.PID_KP) ~= handles.kpGainSlider.UserData)
        ST = dbstack();
        csNames = {ST.name};
        
        if(sum(strcmpi('kpGainSlider_Callback',csNames)) == 1)
            pidController.setPIDParam(NNS_PidController.PID_KP, handles.kpGainSlider.UserData);
            if(okayToRunSimulation)
                simulateAndPlotResults(handles);
            end
        end
    end
    
    % --- Executes during object creation, after setting all properties.
function kpGainSlider_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to kpGainSlider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
    
    % --- Executes on slider movement.
function kiGainSlider_Callback(hObject, eventdata, handles, cb)
    % hObject    handle to kiGainSlider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    pidController = getSelPidController(handles);
    cb(hObject,eventdata);
    okayToRunSimulation = getappdata(handles.editShipPidControllersGUI,'okayToRunSimulation');
    
    if(pidController.getPIDParam(NNS_PidController.PID_KI) ~= handles.kiGainSlider.UserData)
        ST = dbstack();
        csNames = {ST.name};
        
        if(sum(strcmpi('kiGainSlider_Callback',csNames)) == 1)
            pidController.setPIDParam(NNS_PidController.PID_KI, handles.kiGainSlider.UserData);
            if(okayToRunSimulation)
                simulateAndPlotResults(handles);
            end
        end
    end
    
    % --- Executes during object creation, after setting all properties.
function kiGainSlider_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to kiGainSlider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
    
    % --- Executes on slider movement.
function kdGainSlider_Callback(hObject, eventdata, handles, cb)
    % hObject    handle to kdGainSlider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    pidController = getSelPidController(handles);
    cb(hObject,eventdata);
    okayToRunSimulation = getappdata(handles.editShipPidControllersGUI,'okayToRunSimulation');
    
    if(pidController.getPIDParam(NNS_PidController.PID_KD) ~= handles.kdGainSlider.UserData)
        ST = dbstack();
        csNames = {ST.name};
        
        if(sum(strcmpi('kdGainSlider_Callback',csNames)) == 1)
            pidController.setPIDParam(NNS_PidController.PID_KD, handles.kdGainSlider.UserData);
            if(okayToRunSimulation)
                simulateAndPlotResults(handles);
            end
        end
    end
    
    % --- Executes during object creation, after setting all properties.
function kdGainSlider_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to kdGainSlider (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
    
function simulateAndPlotResults(handles)
    handles.computingResponseLabel.Visible = 'on';
    drawnow nocallbacks;
    try
        ship = getappdata(handles.editShipPidControllersGUI,'ship');
        ship.inializePropObj();
        ship.stateMgr.setZeroPositionAndHeadingAndNoVel();
        
        pidController = getSelPidController(handles);
        
        speedCntrlr = ship.basicPropagator.speedCntrlr;
        headingCntrlr = ship.basicPropagator.headingCntrlr;
        
        if(handles.pidControllerSelButtonGrp.SelectedObject == handles.speedControllerRadioBtn)
            initCond = str2double(handles.initConditionsText.String);
            setpoint = str2double(handles.setPointText.String);
            
            ship.stateMgr.velocity(1) = initCond;
            pidController.setPIDParam(NNS_PidController.PID_SETPOINT, setpoint);
            headingCntrlr.setPIDParam(NNS_PidController.PID_SETPOINT, 0);
        elseif(handles.pidControllerSelButtonGrp.SelectedObject == handles.headingControllerRadioBtn)
            initCond = rad2deg(angleZero2Pi(deg2rad(str2double(handles.initConditionsText.String))));
            initCondRate = deg2rad(str2double(handles.initCondRateText.String));
            setpoint = rad2deg(angleZero2Pi(deg2rad(str2double(handles.setPointText.String))));
            
            ship.stateMgr.heading = deg2rad(initCond);
            ship.stateMgr.angRate = initCondRate;
            
            pidController.setPIDParam(NNS_PidController.PID_SETPOINT, deg2rad(setpoint));
            speedCntrlr.setPIDParam(NNS_PidController.PID_SETPOINT, 0);
        else
            error('Unknown PID Controller radio button selection.');
        end
        
        oldArena = ship.arena;
        newArena = NNS_Arena([-Inf Inf],[-Inf Inf]);
        
        simClock = NNS_SimClock(0, 20, 0, 1/10);
        ship.arena = newArena;
        ship.arena.simClock = simClock;
        simClock.curSimTime = 0;  %seconds
        
        timeHistory = simClock.startTime:simClock.timeStep:simClock.endTime;
        shipVelHistory = zeros(size(timeHistory));
        shipHeadingHistory = zeros(size(timeHistory));
        for(t = timeHistory) %#ok<*NO4LP>
            handles.computingResponseLabel.String = sprintf('Computing Response... %.2f%%%', 100*t/max(timeHistory));
            drawnow nocallbacks;
            
            simClock.curSimTime = t;
            ship.basicPropagator.propagateOneStep(simClock.timeStep, ship.arena.xLims, ship.arena.yLims);
            
            shipVelHistory(t == timeHistory) = norm(ship.stateMgr.velocity);
            shipHeadingHistory(t == timeHistory) = rad2deg(ship.stateMgr.heading);
        end
        
        cla(handles.outputAxes);
        hold(handles.outputAxes,'on');
        plot(handles.outputAxes, [min(timeHistory), max(timeHistory)], [setpoint, setpoint], '--r');
        
        if(handles.pidControllerSelButtonGrp.SelectedObject == handles.speedControllerRadioBtn)
            plot(handles.outputAxes, timeHistory, shipVelHistory);
            ylabel('Speed [m/s]');
        elseif(handles.pidControllerSelButtonGrp.SelectedObject == handles.headingControllerRadioBtn)
            plot(handles.outputAxes, timeHistory, shipHeadingHistory);
            ylabel('Heading [deg]');
        end
        xlabel('Time [sec]');
        grid(handles.outputAxes,'on');
        hold(handles.outputAxes,'off');
    catch ME
        warning(ME.message);
    end
    ship.arena = oldArena;
    handles.computingResponseLabel.Visible = 'off';
    
    
    % --- Executes during object creation, after setting all properties.
function outputAxes_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to outputAxes (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: place code in OpeningFcn to populate outputAxes
    grid(hObject,'on');
    
    
    % --- Executes when selected object is changed in pidControllerSelButtonGrp.
function pidControllerSelButtonGrp_SelectionChangedFcn(hObject, ~, handles)
    % hObject    handle to the selected object in pidControllerSelButtonGrp
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    pidController = getSelPidController(handles);
    sliderResolution = getappdata(handles.editShipPidControllersGUI,'sliderResolution');
    
    if(handles.pidControllerSelButtonGrp.SelectedObject == handles.speedControllerRadioBtn)
        ship = getappdata(handles.editShipPidControllersGUI,'ship');
        [~, ~, ~, termVel] = getShipLinearTermVel(ship);
        
        handles.initCondUnitLabel.String = 'm/s';
        handles.initConditionsText.String = '0.0';
        handles.initCondRateUnitLabel.String = 'm/s';
        handles.initCondRateText.String = '0.0';
        handles.setPointUnitLabel.String = 'm/s';
        handles.setPointText.String = num2str(termVel,3);
        
        handles.initCondRateText.Enable = 'off';
        
    elseif(handles.pidControllerSelButtonGrp.SelectedObject == handles.headingControllerRadioBtn)
        handles.initCondUnitLabel.String = 'deg';
        handles.initConditionsText.String = '0.0';
        handles.initCondRateUnitLabel.String = 'deg/s';
        handles.initCondRateText.String = '0.0';
        handles.setPointUnitLabel.String = 'deg';
        handles.setPointText.String = '180';
        
        handles.initCondRateText.Enable = 'on';
    else
        error('Unknown PID Controller radio button selection.');
    end    
    
    setappdata(handles.editShipPidControllersGUI,'okayToRunSimulation',false);
    
    setPointText_Callback(handles.setPointText, [], handles);
    initConditionsText_Callback(handles.initConditionsText, [], handles);
    initCondRateText_Callback(handles.initCondRateText, [], handles);
    
    setappdata(hObject,'okayToRunSimulation',false);
    handles.kpGainSlider.JavaComponent.setValue(pidController.getPIDParam(NNS_PidController.PID_KP)/sliderResolution);
    handles.kiGainSlider.JavaComponent.setValue(pidController.getPIDParam(NNS_PidController.PID_KI)/sliderResolution);
    handles.kdGainSlider.JavaComponent.setValue(pidController.getPIDParam(NNS_PidController.PID_KD)/sliderResolution);
    setappdata(handles.editShipPidControllersGUI,'okayToRunSimulation',true);
    
    simulateAndPlotResults(handles);
    
    
    
function setPointText_Callback(hObject, eventdata, handles)
    % hObject    handle to setPointText (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of setPointText as text
    %        str2double(get(hObject,'String')) returns contents of setPointText as a double
    newInput = attemptStrEval(get(hObject,'String'));
    set(hObject, 'String', newInput);
    
    errMsg = {};
    
    x = str2double(get(handles.setPointText,'String'));
    enteredStr = get(handles.setPointText,'String');
    numberName = 'PID Controller Set Point Value';
    lb = -Inf;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(x, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))
        hObject.UserData = newInput;
        
        okayToRunSimulation = getappdata(handles.editShipPidControllersGUI,'okayToRunSimulation');
        if(okayToRunSimulation)
            simulateAndPlotResults(handles);
        end
    else
        msgbox(errMsg,'Set Point Input Error','error');
        set(hObject, 'String', hObject.UserData);
    end
    
    
    % --- Executes during object creation, after setting all properties.
function setPointText_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to setPointText (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function initConditionsText_Callback(hObject, eventdata, handles)
    % hObject    handle to initConditionsText (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of initConditionsText as text
    %        str2double(get(hObject,'String')) returns contents of initConditionsText as a double
    newInput = attemptStrEval(get(hObject,'String'));
    set(hObject, 'String', newInput);
    
    errMsg = {};
    
    x = str2double(get(handles.setPointText,'String'));
    enteredStr = get(handles.setPointText,'String');
    numberName = 'Initial Condition (Upper) Value';
    lb = -Inf;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(x, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))
        hObject.UserData = newInput;
        
        okayToRunSimulation = getappdata(handles.editShipPidControllersGUI,'okayToRunSimulation');
        if(okayToRunSimulation)
            simulateAndPlotResults(handles);
        end
    else
        msgbox(errMsg,'Initial Conditon Input Error','error');
        set(hObject, 'String', hObject.UserData);
    end
    
    
    % --- Executes during object creation, after setting all properties.
function initConditionsText_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to initConditionsText (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function initCondRateText_Callback(hObject, eventdata, handles)
% hObject    handle to initCondRateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initCondRateText as text
%        str2double(get(hObject,'String')) returns contents of initCondRateText as a double
    newInput = attemptStrEval(get(hObject,'String'));
    set(hObject, 'String', newInput);
    
    errMsg = {};
    
    x = str2double(get(handles.setPointText,'String'));
    enteredStr = get(handles.setPointText,'String');
    numberName = 'Initial Condition (Lower) Value';
    lb = -Inf;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(x, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))
        hObject.UserData = newInput;
        
        okayToRunSimulation = getappdata(handles.editShipPidControllersGUI,'okayToRunSimulation');
        if(okayToRunSimulation)
            simulateAndPlotResults(handles);
        end
    else
        msgbox(errMsg,'Initial Conditon Input Error','error');
        set(hObject, 'String', hObject.UserData);
    end

% --- Executes during object creation, after setting all properties.
function initCondRateText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initCondRateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
