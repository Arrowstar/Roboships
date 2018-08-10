function varargout = enterMathExpressionGUI(varargin)
    % ENTERMATHEXPRESSIONGUI MATLAB code for enterMathExpressionGUI.fig
    %      ENTERMATHEXPRESSIONGUI, by itself, creates a new ENTERMATHEXPRESSIONGUI or raises the existing
    %      singleton*.
    %
    %      H = ENTERMATHEXPRESSIONGUI returns the handle to a new ENTERMATHEXPRESSIONGUI or the handle to
    %      the existing singleton*.
    %
    %      ENTERMATHEXPRESSIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in ENTERMATHEXPRESSIONGUI.M with the given input arguments.
    %
    %      ENTERMATHEXPRESSIONGUI('Property','Value',...) creates a new ENTERMATHEXPRESSIONGUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before enterMathExpressionGUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to enterMathExpressionGUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help enterMathExpressionGUI
    
    % Last Modified by GUIDE v2.5 30-Jul-2018 18:03:01
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @enterMathExpressionGUI_OpeningFcn, ...
        'gui_OutputFcn',  @enterMathExpressionGUI_OutputFcn, ...
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
    
    
    % --- Executes just before enterMathExpressionGUI is made visible.
function enterMathExpressionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to enterMathExpressionGUI (see VARARGIN)
    
    % Choose default command line output for enterMathExpressionGUI
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
    setappdata(hObject,'cmdMap',NNS_ObjectToControllerObjectMap.getMap());
    
    expParam = NNS_MathControllerParameter(ship);
    setappdata(hObject,'mathExprParam',expParam);
    mathExpr = NNS_ControllerEmptyMathExpression();
    
    expParam.math = mathExpr;
    setappdata(hObject,'mathExprParam',expParam);
    
    %Setup UI
    handles = setupGUI(ship, handles);
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes enterMathExpressionGUI wait for user response (see UIRESUME)
    uiwait(handles.enterMathExpressionGUI);
    
    
function handles = setupGUI(ship, handles)
    controller = getController(handles.enterMathExpressionGUI);
    mathExprParam = getappdata(handles.enterMathExpressionGUI,'mathExprParam');
    
    jTextPane = javaObjectEDT('javax.swing.JTextPane');
    [~,~] = javacomponent(jTextPane,handles.expressionText.Position,handles.expressPanel);
    delete(handles.expressionText);
    jTextPane.setEditable(false);
    jTextPane.getCaret().setVisible(true);
    jTextPane.getCaret().setSelectionVisible(true);
    jTextPane.setContentType('text/html');
    jTextPane.setText('<html>Test<b>T</b>ext</html>');
    jTextPane.getCaretPosition();
    jTextPane.setText(mathExprParam.getValueAsStr());
    
    caret = jTextPane.getCaret();
    caret.setUpdatePolicy(javax.swing.text.DefaultCaret.NEVER_UPDATE);
    
    handles.expressionText = jTextPane;
    set(jTextPane,'CaretUpdateCallback', @(src, evt) caretUpdateCallback(src, evt, handles));
    
    setShipCompComboBox(ship, handles.componentSelCombo);
    componentSelCombo_Callback(handles.componentSelCombo, [], handles);
    
    set(handles.variablesListbox,'String',controller.getVariableList().getListboxStr());
    
    hFields = fields(handles);
    for(i=1:length(hFields))
        gObj = handles.(hFields{i});
        
        if(isprop(gObj,'KeyPressFcn'))
            set(gObj,'KeyPressFcn',@(src, evt) univKeypressHandler(src, evt, handles));
        end
    end
    
    
function caretUpdateCallback(src, evt, handles)
    mathExprParam = getappdata(handles.enterMathExpressionGUI,'mathExprParam');
    mathExp = mathExprParam.math;
    
    caretLoc = evt.getDot();
    
    mathExp.setSelectedState(false);
    
    startEndTable = mathExp.getStartEndIndicesTable(1,{});
    startEndTable = sortrows(startEndTable,4,'ascend');
    filteredTable = startEndTable([startEndTable{:,2}]<=caretLoc & [startEndTable{:,3}]>caretLoc,:);
    
    if(not(isempty(filteredTable)))
        row = filteredTable(1,:);
        expressToSel = row{1};
        
        mathExp.setSelectedState(false); %clears out old selection
        expressToSel.setSelectedState(true);
        
        formattedStr = mathExp.getExpressionAsString(false);
        src.setText(formattedStr);
    end
    
    src.setEnabled(false);
    src.setEnabled(true);
    
    
function expressToSel = getSelectedMathExpression(handles)
    mathExprParam = getappdata(handles.enterMathExpressionGUI,'mathExprParam');
    expressToSel = mathExprParam.getSelectedExpr();
    
    
    
    
    % --- Outputs from this function are returned to the command line.
function varargout = enterMathExpressionGUI_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    mathExprParam = getappdata(hObject,'mathExprParam');
    varargout{1} = mathExprParam;
    delete(hObject);
    
    
    % --- Executes on selection change in componentSelCombo.
function componentSelCombo_Callback(hObject, eventdata, handles)
    % hObject    handle to componentSelCombo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns componentSelCombo contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from componentSelCombo
    cmdMap = getappdata(handles.enterMathExpressionGUI,'cmdMap');
    comp = getSelectedComp(handles.componentSelCombo, handles.enterMathExpressionGUI);
    compClass = class(comp);
    
    set(handles.parameterListbox, 'String', cmdMap.getListboxStr(compClass,NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter));
    set(handles.parameterListbox, 'Value', 1);
    
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
    
    
    % --- Executes on selection change in parameterListbox.
function parameterListbox_Callback(hObject, eventdata, handles)
    % hObject    handle to parameterListbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns parameterListbox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from parameterListbox
    selType = get(handles.enterMathExpressionGUI,'selectiontype');
    
    if(strcmpi(selType,'open'))
        cmdMap = getappdata(handles.enterMathExpressionGUI,'cmdMap');
        comp = getSelectedComp(handles.componentSelCombo, handles.enterMathExpressionGUI);
        
        contents = cellstr(get(hObject,'String'));
        sel = strip(contents{get(hObject,'Value')});
        
        [param, ~] = cmdMap.getControllerObjForListboxStr(sel, comp);
        
        if(isa(param,'NNS_ConstantControllerParameter') || ...
                isa(param,'NNS_MathControllerParameter'))
            return;
        end
        
        newExpr = NNS_ControllerParameterMathExpression(param);
        setNewExpression(newExpr, handles);
    end
    
    % --- Executes during object creation, after setting all properties.
function parameterListbox_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to parameterListbox (see GCBO)
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
    mathExprParam = getappdata(handles.enterMathExpressionGUI,'mathExprParam');
    isValid = mathExprParam.math.isExpressionValid();
    
    if(isValid)
        close(handles.enterMathExpressionGUI);
    else
        warndlg('The entered math expression does not appear to be valid.  Check to make sure that it is not missing any inputs (denoted by "?").');
    end
    
function setNewExpression(newExpr, handles)
    mathExprParam = getappdata(handles.enterMathExpressionGUI,'mathExprParam');
    expressSel = getSelectedMathExpression(handles);
    
    if(not(isempty(expressSel)))
        parent = expressSel.parent;
        
        if(newExpr.numInputs >= 1)
            newExpr.setInput(expressSel,1);
        end
        
        if(not(isempty(parent)))
            for(i=1:parent.numInputs) %#ok<*NO4LP>
                if(parent.inputs(i) == expressSel)
                    parent.setInput(newExpr,i);
                end
            end
        else
            mathExprParam.math = newExpr;
        end
        
        
        handles.expressionText.setText(mathExprParam.getValueAsStr());
    end
    
    
    % --- Executes on button press in sineOpButton.
function sineOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to sineOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerSineMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in cosineOpButton.
function cosineOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to cosineOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerCosineMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in tanOpButton.
function tanOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to tanOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerTangentMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in asineOpButton.
function asineOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to asineOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerArcSineMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in acosineOpButton.
function acosineOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to acosineOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerArcCosineMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in atanOpButton.
function atanOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to atanOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerArcTangentMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in atan2OpButton.
function atan2OpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to atan2OpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerArcTangent2MathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in absOpButton.
function absOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to absOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerAbsMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in sqrtOpButton.
function sqrtOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to sqrtOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerSqrtMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in randOpButton.
function randOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to randOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerRandMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in hypotOpButton.
function hypotOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to hypotOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerHypotMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in rootOpButton.
function rootOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to rootOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerNthRootMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in powOpButton.
function powOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to powOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerPowMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in deg2radOpButton.
function deg2radOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to deg2radOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerDeg2RadMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in rad2degOpButton.
function rad2degOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to rad2degOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerRad2DegMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in additionOpButton.
function additionOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to additionOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerAdditionMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in subtractionOpButton.
function subtractionOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to subtractionOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerSubtractionMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in multiOpButton.
function multiOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to multiOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerMultiplicationMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in divisionOpButton.
function divisionOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to divisionOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerDivisionMathExpression();
    setNewExpression(newExpr, handles);
    
    
    
    % --- Executes on button press in parenOpButton.
function parenOpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to parenOpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    newExpr = NNS_ControllerParenMathExpression();
    setNewExpression(newExpr, handles);
    
    % --- Executes on button press in insertionConstantButton.
function insertionConstantButton_Callback(hObject, eventdata, handles)
    % hObject    handle to insertionConstantButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    x = inputdlg('Enter value of constant.  Value must be numeric and finite.', 'New Constant', [1 50]);
    
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
            newExpr = NNS_ControllerConstantMathExpression(const);
            setNewExpression(newExpr, handles);
        else
            msgbox(errMsg,'New Constant Input Error','error');
            
            return;
        end
    end
    
    
    
    % --- Executes on selection change in variablesListbox.
function variablesListbox_Callback(hObject, eventdata, handles)
    % hObject    handle to variablesListbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns variablesListbox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from variablesListbox
    selType = get(handles.enterMathExpressionGUI,'selectiontype');
    
    if(strcmpi(selType,'open'))
        var = getSelectedVariable(handles.variablesListbox, handles.enterMathExpressionGUI);
        
        if(not(isempty(var)))
            varExpr = NNS_ControllerVariableMathExpression(var);
            setNewExpression(varExpr, handles);
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
    
    
function univKeypressHandler(src, eventdata, handles)
    if(strcmpi(eventdata.Key,'delete'))
        newExpr = NNS_ControllerEmptyMathExpression();
        setNewExpression(newExpr, handles);
    end
    
    
    % --- Executes when user attempts to close enterMathExpressionGUI.
function enterMathExpressionGUI_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to enterMathExpressionGUI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: delete(hObject) closes the figure
    uiresume(handles.enterMathExpressionGUI);