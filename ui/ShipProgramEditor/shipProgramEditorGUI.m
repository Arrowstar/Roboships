function varargout = shipProgramEditorGUI(varargin)
    % SHIPPROGRAMEDITORGUI MATLAB code for shipProgramEditorGUI.fig
    %      SHIPPROGRAMEDITORGUI, by itself, creates a new SHIPPROGRAMEDITORGUI or raises the existing
    %      singleton*.
    %
    %      H = SHIPPROGRAMEDITORGUI returns the handle to a new SHIPPROGRAMEDITORGUI or the handle to
    %      the existing singleton*.
    %
    %      SHIPPROGRAMEDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in SHIPPROGRAMEDITORGUI.M with the given input arguments.
    %
    %      SHIPPROGRAMEDITORGUI('Property','Value',...) creates a new SHIPPROGRAMEDITORGUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before shipProgramEditorGUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to shipProgramEditorGUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help shipProgramEditorGUI
    
    % Last Modified by GUIDE v2.5 28-Jul-2018 14:58:47
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @shipProgramEditorGUI_OpeningFcn, ...
        'gui_OutputFcn',  @shipProgramEditorGUI_OutputFcn, ...
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
    
    
    % --- Executes just before shipProgramEditorGUI is made visible.
function shipProgramEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to shipProgramEditorGUI (see VARARGIN)
    
    % Choose default command line output for shipProgramEditorGUI
    handles.output = hObject;
    
    if(numel(varargin) >= 1)
        ship = varargin{1};
        controller = varargin{2};
    else
        arena = NNS_Arena([-25 25], [-25 25]);
        ship = NNS_Ship.createDefaultBasicShip(arena);
        controllers = ship.components.getControllerComps();
        controller = controllers(1);
    end
    setappdata(hObject,'ship',ship);
    setappdata(hObject,'controller',controller);
    setappdata(hObject,'connTracker',NNS_CommandConnectionTracker());
    setappdata(hObject,'cmdMap',NNS_ObjectToControllerObjectMap.getMap());
    setappdata(hObject,'selectedCmd',NNS_AbstractControllerOperation.empty(0,0));
    
    %Setup GUI
    hWaitbar = waitbar(0.5,'Loading Ship Program, please wait...');
%     profile on;
    handles = setGUI(handles);
%     profile viewer;
    close(hWaitbar);
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes shipProgramEditorGUI wait for user response (see UIRESUME)
    uiwait(handles.shipProgramEditorGUI);
    
function handles = setGUI(handles)
    ship = getappdata(handles.shipProgramEditorGUI,'ship');
    
    controller = getController(handles.shipProgramEditorGUI);
    mainSR = controller.getMainSubroutine();
    
    drawSubroutineOnAxes(mainSR, handles);
    
    set(handles.subroutineCombo,'String',{controller.getAllSubroutines().name});
    set(handles.subroutineCombo,'Value',1);
        
    setShipCompComboBox(ship, handles.componentSelCombo);
    
    componentSelCombo_Callback(handles.componentSelCombo, [], handles);
    
    createParamAnnot(handles);
    createVarAnnot(handles);
    
    set(handles.variablesListbox,'String',controller.getVariableList().getListboxStr());
    
    hFields = fields(handles);
    for(i=1:length(hFields))
        gObj = handles.(hFields{i});
        
        if(isprop(gObj,'KeyPressFcn'))
            set(gObj,'KeyPressFcn',@(src, evt) univKeypressHandler(src, evt, handles));
        end
    end
    
    
function createParamAnnot(handles)
    paramAnnotPos = [0 0 2 1];
    paramDragAnnot = annotation(handles.shipProgramEditorGUI, 'textbox','String','Param','Position',paramAnnotPos,'FitBoxToText','on',...
        'Margin',0,'HorizontalAlignment','center','BackgroundColor','w','Color','k',...
        'VerticalAlignment','middle','PickableParts','none','FontSize',7,'Interpreter','none', ...
        'Visible','off');
    setappdata(handles.shipProgramEditorGUI,'paramDragAnnot',paramDragAnnot);
    setappdata(handles.shipProgramEditorGUI,'isDraggingParam',false);
    
function createVarAnnot(handles)
    varAnnotPos = [0 0 2 1];
    varDragAnnot = annotation(handles.shipProgramEditorGUI, 'textbox','String','Variable','Position',varAnnotPos,'FitBoxToText','on',...
        'Margin',0,'HorizontalAlignment','center','BackgroundColor','w','Color','k',...
        'VerticalAlignment','middle','PickableParts','none','FontSize',7,'Interpreter','none', ...
        'Visible','off');
    setappdata(handles.shipProgramEditorGUI,'varDragAnnot',varDragAnnot);
    setappdata(handles.shipProgramEditorGUI,'isDraggingVar',false);
    
function drawSubroutineOnAxes(subroutine, handles)
    cmds = subroutine.operations;
    
    for(i=1:length(cmds)) %#ok<*NO4LP>
        cmd = cmds(i);
        
        if(not(isempty(cmd.drawer)))
            cmd.drawer.drawObjectOnAxes(handles.programCanvassAxes);
        end
    end
    
    for(i=1:length(cmds))
        cmd = cmds(i);
        
        if(not(isempty(cmd.drawer)))
            for(j=1:cmd.numOutputs)
                nextOp = cmd.getNextOperationForIndForProgrammingUI(j);

                if(not(isempty(nextOp)) && not(isempty(nextOp.drawer)))
                    connTracker = getappdata(handles.shipProgramEditorGUI,'connTracker');
                    [cPolyOut, cmdOut, oCmd, id] = cmd.drawer.connectCommandBlockToAnotherCommandBlock(nextOp,j);
                    connTracker.addConnection(cPolyOut, cmdOut, oCmd, id);
                end
            end
        end
    end
    
    
    % --- Outputs from this function are returned to the command line.
function varargout = shipProgramEditorGUI_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = getappdata(hObject,'ship');
    delete(hObject);
    
    
    % --- Executes on selection change in componentSelCombo.
function componentSelCombo_Callback(hObject, eventdata, handles)
    % hObject    handle to componentSelCombo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns componentSelCombo contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from componentSelCombo
    cmdMap = getappdata(handles.shipProgramEditorGUI,'cmdMap');
    comp = getSelectedComp(handles.componentSelCombo, handles.shipProgramEditorGUI);
    compClass = class(comp);
    
    types = [NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition, ...
             NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation, ...
             NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter];
    set(handles.commandListbox, 'String', cmdMap.getListboxStr(compClass, types));
    set(handles.commandListbox, 'Value', 1);
    
    
    % --- Executes during object creation, after setting all properties.
function componentSelCombo_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to componentSelCombo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on selection change in commandListbox.
function commandListbox_Callback(hObject, eventdata, handles)
    % hObject    handle to commandListbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns commandListbox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from commandListbox
    selType = get(handles.shipProgramEditorGUI,'selectiontype');
    
    if(strcmpi(selType,'open'))
        selSubR = getSelectedSubroutine(handles);
        cmdMap = getappdata(handles.shipProgramEditorGUI,'cmdMap');
        comp = getSelectedComp(handles.componentSelCombo, handles.shipProgramEditorGUI);
        
        contents = cellstr(get(hObject,'String'));
        sel = strip(contents{get(hObject,'Value')});
        
        [cmd, entry] = cmdMap.getControllerObjForListboxStr(sel, comp);
        
        if(not(isempty(cmd)))
            if(entry.type == NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation || ...
                    entry.type == NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition)
               
                if(isa(cmd,'NNS_ExecuteSubroutineCntrlrOperation'))
                    controller = getController(handles.shipProgramEditorGUI);
                    
                    str = {controller.getAllSubroutines().name};
                    if(length(str) >= 2)
                        str = str(2:end);
                        [Selection,ok] = listdlg('PromptString','Select a subroutine:',...
                                        'SelectionMode','single',...
                                        'ListString',str);
                        if(ok == 0)
                            return;
                        else
                            subroutine = controller.getSubroutineForIndex(1+Selection);
                            cmd.subroutine = subroutine;
                        end
                    else
                        warndlg('There are no additional subroutines to execute.  The "main" subroutine may not be called as a subroutine in this manner.');
                    end
                end
                
                selSubR.addOperation(cmd);
                cmd.drawer.drawObjectOnAxes(handles.programCanvassAxes);
            elseif(entry.type == NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter)
                setappdata(handles.shipProgramEditorGUI,'isDraggingParam',true);

                if(isa(cmd,'NNS_ConstantControllerParameter'))
                    x = inputdlg('Enter value of new constant.  Value must be numeric and finite.', 'New Constant', [1 50]);

                    if(not(isempty(x)))
                        errMsg = {};
                        const = str2double(x{1});
                        enteredStr = x{1};
                        numberName = 'New Constant';
                        lb = -realmax;
                        ub = realmax;
                        isInt = false;
                        errMsg = validateNumber(const, numberName, lb, ub, isInt, errMsg, enteredStr);

                        if(isempty(errMsg))
                            cmd.setConstValue(const);
                        else
                            msgbox(errMsg,'New Constant Input Error','error');

                            return;
                        end
                    end
                elseif(isa(cmd,'NNS_MathControllerParameter'))
                    ship = getappdata(handles.shipProgramEditorGUI,'ship');
                    paramMath = enterMathExpressionGUI(ship, getController(handles.shipProgramEditorGUI));
                    cmd.math = paramMath.math;
                end

                paramDragAnnot = getappdata(handles.shipProgramEditorGUI,'paramDragAnnot');
                paramDragAnnot.Visible = 'on';
                paramDragAnnot.String = cmd.getValueAsStr();
                uistack(paramDragAnnot,'top');

                paramDragAnnot.UserData = cmd;
                setParamDragAnnotToMouseCursor(paramDragAnnot, handles);
            end
        end
    end
    
    
    % --- Executes during object creation, after setting all properties.
function commandListbox_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to commandListbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on button press in saveAndCloseButton.
function saveAndCloseButton_Callback(hObject, eventdata, handles)
    % hObject    handle to saveAndCloseButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    close(handles.shipProgramEditorGUI);
    
    % --- Executes during object creation, after setting all properties.
function programCanvassAxes_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to programCanvassAxes (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: place code in OpeningFcn to populate programCanvassAxes
    configureAxes(hObject);
    
    
function configureAxes(hAxes)
    hAxes.SortMethod = 'childorder';
    hAxes.Color = [0.69, 0.878, 0.902];
    hAxes.XLimMode = 'manual';
    hAxes.XLim = [-10 10];
    hAxes.XTick = [hAxes.XLim(1):hAxes.XLim(2)]; %#ok<NBRAK>
    hAxes.YLimMode = 'manual';
    hAxes.YLim = [-10 10];
    hAxes.YTick = [hAxes.YLim(1):hAxes.YLim(2)]; %#ok<NBRAK>
    hAxes.XTickLabel = {};
    hAxes.YTickLabel = {};
    %     grid(hAxes,'on');
    grid(hAxes,'minor');
    
    
    % --- Executes on mouse press over figure background, over a disabled or
    % --- inactive control, or over an axes background.
function shipProgramEditorGUI_WindowButtonUpFcn(hObject, eventdata, handles)
    % hObject    handle to shipProgramEditorGUI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    selType = get(handles.shipProgramEditorGUI,'selectiontype');
    cmd = getClickedCmd(handles);
    
    if(strcmpi(selType,'alt'))
        if(not(isempty(cmd)))
            disconnectCmdBlockFromAllConnectedBlocks(cmd, handles);
        end
    elseif(strcmpi(selType,'normal'))       
        %handle dragging of parameters
        paramDragAnnot = getappdata(handles.shipProgramEditorGUI,'paramDragAnnot');
        param = paramDragAnnot.UserData;
        if(not(isempty(param)) && not(isempty(cmd)))
            cmd.setNumeric(param);
            cmd.drawer.refreshText();
        end
        
        setappdata(handles.shipProgramEditorGUI,'isDraggingParam',false);
        paramDragAnnot.Visible = 'off';
        paramDragAnnot.UserData = [];
        setappdata(handles.shipProgramEditorGUI,'paramDragAnnot', paramDragAnnot);
        
        %handle dragging of parameters
        varDragAnnot = getappdata(handles.shipProgramEditorGUI,'varDragAnnot');
        var = varDragAnnot.UserData;
        if(not(isempty(var)) && not(isempty(cmd)))
            cmd.setNumeric(var);
            cmd.drawer.refreshText();
        end
        
        setappdata(handles.shipProgramEditorGUI,'isDraggingVar',false);
        varDragAnnot.Visible = 'off';
        varDragAnnot.UserData = [];
        setappdata(handles.shipProgramEditorGUI,'varDragAnnot', varDragAnnot);
        
        %Click connection circles
        if(not(isempty(cmd)))
            [cmdForClickedCircle, circInd] = getCmdForClickedCircle(handles);
            
            if(not(cmdForClickedCircle == cmd))
                cmdForClickedCircle.setNextOperationForInd(cmd, circInd);
                [cPolyOut, cmdOut, oCmd, id] = cmdForClickedCircle.drawer.connectCommandBlockToAnotherCommandBlock(cmd, circInd);
                
                cmdForClickedCircle.drawer.updateSecondNode = false;
                connTracker = getappdata(handles.shipProgramEditorGUI,'connTracker');
                connTracker.addConnection(cPolyOut, cmdOut, oCmd, id);
                pause(0.5);
                cmdForClickedCircle.drawer.updateSecondNode = true;
            end
        end
    end
    
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function shipProgramEditorGUI_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to shipProgramEditorGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    cmd = getClickedCmd(handles);
    
    if(not(isempty(cmd)))
        setCmdAsSelected(cmd, handles);
    end
    
    
function disconnectCmdBlockFromAllConnectedBlocks(cmd, handles)
    connTracker = getappdata(handles.shipProgramEditorGUI,'connTracker');

    conns = connTracker.getConnectionsToCmd(cmd);
    for(j=1:length(conns))
        conn = conns(j);
        fromCmd = conn.fromCmd;
        toCmd = conn.toCmd;
        id = conn.id;

        if(not(isempty(fromCmd.drawer)))
            circId = fromCmd.drawer.disConnectCommandBlockFromAnotherCommandBlock(toCmd, id);
        end

        if(not(isempty(circId)))
            fromCmd.setNextOperationForInd(NNS_AbstractControllerOperation.empty(0,0), circId);
        end
    end
    
function clickedCmd = getClickedCmd(handles)
    selSubR = getSelectedSubroutine(handles);
    cmds = selSubR.operations;
    
    C = get(handles.programCanvassAxes, 'CurrentPoint');
    C = C(1,1:2);
    
    clickedCmd = [];
    for(i=1:length(cmds))
        cmd = cmds(i);
        if(not(isempty(cmd.drawer)))
            cmdBoxPos = cmd.drawer.getCmdBoxPosition();
            
            in = inpolygon(C(1),C(2),cmdBoxPos(:,1),cmdBoxPos(:,2));
            
            if(in)
                clickedCmd = cmd;
                
                break;
            end
        end
    end
    
    
function [cmdForClickedCircle, circInd] = getCmdForClickedCircle(handles)
    selSubR = getSelectedSubroutine(handles);
    cmds = selSubR.operations;
    
    C = get(handles.programCanvassAxes, 'CurrentPoint');
    C = C(1,1:2);
    
    cmdForClickedCircle = [];
    circInd = [];
    for(i=1:length(cmds))
        cmd = cmds(i);
        if(not(isempty(cmd.drawer)))
            allCirPos = cmd.drawer.getCirclePositions();
            
            for(j=1:size(allCirPos,1))
                cirPos = allCirPos(j,:);
                
                center = cirPos(1:2) + cirPos(3:4)/2;
                radius = min(cirPos(3:4)/2);
                
                distBetweenCircCenterAndClick = pdist2(center, C, 'euclidean');
                
                if(distBetweenCircCenterAndClick < radius)
                    cmdForClickedCircle = cmd;
                    circInd = j;
                    
                    break;
                end
            end
        end
    end
    
    
    % --- Executes when user attempts to close shipProgramEditorGUI.
function shipProgramEditorGUI_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to shipProgramEditorGUI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: delete(hObject) closes the figure
    uiresume(hObject);
    
    
    % --- Executes on selection change in subroutineCombo.
function subroutineCombo_Callback(hObject, eventdata, handles)
    % hObject    handle to subroutineCombo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns subroutineCombo contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from subroutineCombo
    selSubR = getSelectedSubroutine(handles);
    cmds = selSubR.operations;
    
    for(i=1:length(cmds))
        cmds(i).drawer.destroyGraphics();
    end
    
    delete(handles.programCanvassAxes.Children);
    delete(findall(handles.shipProgramEditorGUI,'type','annotation'));
        
    createParamAnnot(handles);
    createVarAnnot(handles);
    
    h = waitbar(0.5,'Loading Subroutine, please wait...');
    drawSubroutineOnAxes(selSubR, handles);
    delete(h);
    
    % --- Executes during object creation, after setting all properties.
function subroutineCombo_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to subroutineCombo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on button press in addSubroutineButton.
function addSubroutineButton_Callback(hObject, eventdata, handles)
    % hObject    handle to addSubroutineButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    controller = getController(handles.shipProgramEditorGUI);
    
    x = inputdlg('Enter subroutine name:', 'Subroutine Name', [1 50]);
    if(not(isempty(x)))
        x = x{1};

        sr = NNS_ControllerSubroutine.getDefaultSubroutine(controller.ship);
        sr.name = x;
        newInd = controller.addSubroutine(sr);

        set(handles.subroutineCombo,'String',{controller.getAllSubroutines().name});
        set(handles.subroutineCombo,'Value',newInd);
        subroutineCombo_Callback(handles.subroutineCombo, [], handles);
    end
    
    % --- Executes on button press in deleteSubroutineButton.
function deleteSubroutineButton_Callback(hObject, eventdata, handles)
    % hObject    handle to deleteSubroutineButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    controller = getController(handles.shipProgramEditorGUI);
    selSubR = getSelectedSubroutine(handles);
    allSubs = controller.getAllSubroutines();
    
    if(length(allSubs) > 1 && controller.getMainSubroutine() ~= selSubR)
        inUse = false;
        for(i=1:length(allSubs))
            sub = allSubs(i);
            
            for(j=1:length(sub.operations))
                op = sub.operations(j);
                
                if(isa(op,'NNS_ExecuteSubroutineCntrlrOperation'))
                    if(op.subroutine == selSubR)
                        inUse = true;
                        break;
                    end
                end
            end
        end
        
        if(inUse == false)
            controller.removeSubroutine(selSubR);
            set(handles.subroutineCombo,'String',{controller.getAllSubroutines().name});
            set(handles.subroutineCombo,'Value',1);
            subroutineCombo_Callback(handles.subroutineCombo, [], handles);
        else
            warndlg('Cannot delete a subroutine if it is the last remaining in the controller, it is the Main subroutine, or it is currently in use.','Cannot Delete Subroutine','modal');
        end
    else
        warndlg('Cannot delete a subroutine if it is the last remaining in the controller, it is the Main subroutine, or it is currently in use.','Cannot Delete Subroutine','modal');
    end
    
    
    % --- Executes on mouse motion over figure - except title and menu.
function shipProgramEditorGUI_WindowButtonMotionFcn(hObject, eventdata, handles)
    % hObject    handle to shipProgramEditorGUI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    isDraggingParam = getappdata(handles.shipProgramEditorGUI,'isDraggingParam');
    isDraggingVar = getappdata(handles.shipProgramEditorGUI,'isDraggingVar');
    
    if(isDraggingParam)
        paramDragAnnot = getappdata(handles.shipProgramEditorGUI,'paramDragAnnot');
        setParamDragAnnotToMouseCursor(paramDragAnnot, handles);
    end
    
    if(isDraggingVar)
        varDragAnnot = getappdata(handles.shipProgramEditorGUI,'varDragAnnot');
        setParamDragAnnotToMouseCursor(varDragAnnot, handles);
    end
    
function setParamDragAnnotToMouseCursor(paramDragAnnot, handles)
    C = get(handles.programCanvassAxes, 'CurrentPoint');
    C = C(1,1:2);
    C = ds2nfu(handles.programCanvassAxes, [C, 3, 0.4]);
    pos = C;
    pos(1:2) = C(1:2) - C(3:4)/2;
    paramDragAnnot.Position = pos;
    
    
    % --- Executes on selection change in variablesListbox.
function variablesListbox_Callback(hObject, eventdata, handles)
    % hObject    handle to variablesListbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns variablesListbox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from variablesListbox
    selType = get(handles.shipProgramEditorGUI,'selectiontype');
    
    if(strcmpi(selType,'open'))
        var = getSelectedVariable(handles.variablesListbox, handles.shipProgramEditorGUI);
        
        if(not(isempty(var)))
            setappdata(handles.shipProgramEditorGUI,'isDraggingVar',true);
            
            varDragAnnot = getappdata(handles.shipProgramEditorGUI,'varDragAnnot');
            varDragAnnot.Visible = 'on';
            varDragAnnot.String = var.getValueAsStr();
            uistack(varDragAnnot,'top');

            varDragAnnot.UserData = var;
            setParamDragAnnotToMouseCursor(varDragAnnot, handles);
            
            setappdata(handles.shipProgramEditorGUI,'varDragAnnot', varDragAnnot);
        end
    end
    
    % --- Executes during object creation, after setting all properties.
function variablesListbox_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to variablesListbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in addVariableButton.
function addVariableButton_Callback(hObject, eventdata, handles)
% hObject    handle to addVariableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    controller = getController(handles.shipProgramEditorGUI);
    varList = controller.getVariableList();
    
    x = inputdlg('Enter new variable name:', 'Variable Name', [1 50]);
    x = strip(x{1});
    
    if(not(varList.doesVarNameExist(x)))
        newVar = NNS_ControllerVariable(x);
        varList.addNewVariable(newVar);
        set(handles.variablesListbox,'String',varList.getListboxStr());
    else
        warndlg(sprintf('A variable with the name "%s" already exists.  Variable names must be unique.  Please choose a new variable name.  Variable was not created.', x));
    end


% --- Executes on button press in removeVariableButton.
function removeVariableButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeVariableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    controller = getController(handles.shipProgramEditorGUI);
    allSubs = controller.getAllSubroutines();
    varList = controller.getVariableList(); 
    
    var = getSelectedVariable(handles.variablesListbox, handles.shipProgramEditorGUI);
    
    if(not(isempty(var)))
        inUse = false;
        for(i=1:length(allSubs))
            sub = allSubs(i);
            
            for(j=1:length(sub.operations))
                op = sub.operations(j);
                
                numerics = op.getNumeric();
                if(not(isempty(numerics)))
                    for(k=1:length(numerics))
                        numeric = numerics(k);
                        
                        if(numeric == var)
                            inUse = true;
                            break;
                        end
                    end                
                end
            end
        end
        
        if(inUse == false)
            varList.removeVariable(var);
            set(handles.variablesListbox,'String',varList.getListboxStr());
            set(handles.variablesListbox,'Value',1);
        else
            warndlg('A variable cannot be deleted if it is in use in a operation or conditional block in a subroutine.','Cannot Delete Variable','modal');
        end
    end
    
    
function univKeypressHandler(src, eventdata, handles)
    if(strcmpi(eventdata.Key,'delete'))
        cmd = getappdata(handles.shipProgramEditorGUI,'selectedCmd');
        if(not(isempty(cmd)) && cmd.isDeletable==true)
            setCmdAsSelected(NNS_AbstractControllerOperation.empty(0,0), handles);
            
            disconnectCmdBlockFromAllConnectedBlocks(cmd, handles);
            
            selSubR = getSelectedSubroutine(handles);
            selSubR.removeOperation(cmd);
            
            cmd.drawer.destroyGraphics();
        end
    end
    
function setCmdAsSelected(cmd, handles)
    oldCmdSel = getappdata(handles.shipProgramEditorGUI,'selectedCmd');
    if(not(isempty(oldCmdSel)))
        oldCmdSel.drawer.setSelected(false);
    end
    
    setappdata(handles.shipProgramEditorGUI,'selectedCmd',cmd);
    if(not(isempty(cmd)))
        cmd.drawer.setSelected(true);
    end
