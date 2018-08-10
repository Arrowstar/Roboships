function varargout = mainGUI(varargin)
    % MAINGUI MATLAB code for mainGUI.fig
    %      MAINGUI, by itself, creates a new MAINGUI or raises the existing
    %      singleton*.
    %
    %      H = MAINGUI returns the handle to a new MAINGUI or the handle to
    %      the existing singleton*.
    %
    %      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in MAINGUI.M with the given input arguments.
    %
    %      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before mainGUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to mainGUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help mainGUI
    
    % Last Modified by GUIDE v2.5 05-Aug-2018 15:35:59
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @mainGUI_OpeningFcn, ...
        'gui_OutputFcn',  @mainGUI_OutputFcn, ...
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
    
    
    % --- Executes just before mainGUI is made visible.
function mainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to mainGUI (see VARARGIN)
    
    % Choose default command line output for mainGUI
    handles.output = hObject;
    
    arena = NNS_Arena(2*[-25 25], 2*[-25 25]);
    
    setappdata(hObject,'arena',arena);
    setappdata(hObject,'loadedShips',{});
    handles.loadedShipsTable.Data = cell(0,size(handles.loadedShipsTable.Data,2));
    updateButtonsBasedOnTableState(handles);
    
    % Update handles structure
    guidata(hObject, handles);
    
    %     UIWAIT makes mainGUI wait for user response (see UIRESUME)
    %     uiwait(handles.mainGUI);
    
    
    % --- Outputs from this function are returned to the command line.
function varargout = mainGUI_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    
    % --- Executes on button press in startBattleButton.
    % hObject    handle to startBattleButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
function startBattleButton_Callback(hObject, eventdata, handles)
    showGraphics = true;
    
    arena = getappdata(handles.mainGUI,'arena');
    loadedShips = getappdata(handles.mainGUI,'loadedShips');
    
    arena.propObjs.removeAllPropObjs();
    
    for(i=1:length(loadedShips))
        ship = loadedShips{i};
        ship.id = rand();
        ship.team = NNS_ShipTeam.getTeamForStr(handles.loadedShipsTable.Data{i,2});
        ship.arena = arena;
        ship.stateMgr.setRandomizedPositionAndHeading([arena.xLims, arena.yLims],[0 360]);
        arena.propObjs.addPropagatedObject(ship);
    end
    
    simDriver = NNS_SimulationDriver(arena,showGraphics);
    arena.simClock = simDriver.clock;
%         profile on;
    try
        simDriver.driveSimulation();
    catch ME
        delete(timerfindall);
        throw(ME);
    end
%         profile viewer;
    
    % --- Executes on button press in newShipButton.
function newShipButton_Callback(hObject, eventdata, handles)
    % hObject    handle to newShipButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    arena = getappdata(handles.mainGUI,'arena');
    loadedShips = getappdata(handles.mainGUI,'loadedShips');
    loadedShips{end+1} = NNS_Ship.createDefaultBasicShip(arena);
    setappdata(handles.mainGUI,'loadedShips',loadedShips);
    
    refreshShipTable(handles);
    
function refreshShipTable(handles)
    loadedShips = getappdata(handles.mainGUI,'loadedShips');
    
    tableData = cell(0,3);
    for(i=1:length(loadedShips)) %#ok<*NO4LP>
        ship = loadedShips{i};
        
        if(not(isempty(ship)))
            changedStr = '';
            if(ship.changed)
                changedStr = '*';
            end

            tableData(end+1,:) = {[ship.name,changedStr],ship.team.str,ship.hull.getMaxHitPoints()}; %#ok<AGROW>
        end
    end
    handles.loadedShipsTable.Data = tableData;
    
    % --- Executes on button press in loadShipButton.
function loadShipButton_Callback(hObject, eventdata, handles)
    % hObject    handle to loadShipButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    [FileName,PathName] = uigetfile({'*.mat','Roboships Ship File (*.mat)'},...
        'Load Ship',...
        'ship.mat');
    filePath = [PathName,FileName];
    
    if(not(FileName == 0))
        load(filePath,'ship');
        if(exist('ship','var'))
            ship.team = NNS_ShipTeam.None;
            
            loadedShips = getappdata(handles.mainGUI,'loadedShips');
            loadedShips{end+1} = ship;
            setappdata(handles.mainGUI,'loadedShips',loadedShips);
            
            refreshShipTable(handles);
        end
    end
    
    % --- Executes on button press in editShipButton.
function editShipButton_Callback(hObject, eventdata, handles)
    % hObject    handle to editShipButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    ship = getSelectedShip(handles);
    
    set(handles.mainGUI,'Visible','off');
    ship = shipCompEditorGUI(ship);
    ship.changed = true;
    set(handles.mainGUI,'Visible','on');
    
    loadedShips = getappdata(handles.mainGUI,'loadedShips');
    tableSel = handles.loadedShipsTable.UserData;
    if(length(tableSel) == 2)
        selRow = tableSel(1);
        
        if(selRow <= length(loadedShips))
            loadedShips{tableSel(1)} = ship;
        end
        
        setappdata(handles.mainGUI,'loadedShips',loadedShips);
        
        refreshShipTable(handles);
    end
    
    % --- Executes on button press in saveShipButton.
function saveShipButton_Callback(hObject, eventdata, handles)
    % hObject    handle to saveShipButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    ship = getSelectedShip(handles);
    
    if(not(isempty(ship)))
        if(isprop(ship,'savedToPath') && not(isempty(ship.savedToPath)))
            ship.changed = false;
            save(ship.savedToPath,'ship');
            
            refreshShipTable(handles);
        else
            saveAsButton_Callback(handles.saveAsButton, [], handles);
        end
    end
    
    
% --- Executes on button press in saveAsButton.
function saveAsButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    ship = getSelectedShip(handles);
    
    if(not(isempty(ship)))
        [FileName,PathName,~] = uiputfile({'*.mat','Roboships Ship File (*.mat)'},...
            'Save Ship','ship.mat');
        
        if(not(FileName == 0))
            filePath = [PathName,FileName];
            ship.savedToPath = filePath;
            ship.changed = false;
            save(filePath,'ship');
            
            refreshShipTable(handles);
        end
    end
    
    % --- Executes on button press in removeShipButton.
function removeShipButton_Callback(hObject, eventdata, handles)
    % hObject    handle to removeShipButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    loadedShips = getappdata(handles.mainGUI,'loadedShips');
    tableSel = handles.loadedShipsTable.UserData;
    if(length(tableSel) == 2)
        selRow = tableSel(1);
        
        if(selRow <= length(loadedShips))
            loadedShips(tableSel(1)) = [];
        end
        
        setappdata(handles.mainGUI,'loadedShips',loadedShips);
        
        refreshShipTable(handles);
    end
    
    
function ship = getSelectedShip(handles)
    loadedShips = getappdata(handles.mainGUI,'loadedShips');
    tableSel = handles.loadedShipsTable.UserData;
    
    ship = NNS_Ship.empty(0,0);
    if(length(tableSel) == 2)
        selRow = tableSel(1);
        
        if(selRow <= length(loadedShips))
            ship = loadedShips{selRow};
        end
    end
    
    % --- Executes when selected cell(s) is changed in loadedShipsTable.
function loadedShipsTable_CellSelectionCallback(hObject, eventdata, handles)
    % hObject    handle to loadedShipsTable (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
    %	Indices: row and column indices of the cell(s) currently selecteds
    % handles    structure with handles and user data (see GUIDATA)
    hObject.UserData = eventdata.Indices;
    updateButtonsBasedOnTableState(handles);
    
function updateButtonsBasedOnTableState(handles)
    tableSel = handles.loadedShipsTable.UserData;
    
    if(isempty(tableSel))
        handles.editShipButton.Enable = 'off';
        handles.saveShipButton.Enable = 'off';
        handles.saveAsButton.Enable = 'off';
        handles.removeShipButton.Enable = 'off';
    else
        handles.editShipButton.Enable = 'on';
        handles.saveShipButton.Enable = 'on';
        handles.saveAsButton.Enable = 'on';
        handles.removeShipButton.Enable = 'on';
    end
    
    
    % --- Executes when entered data in editable cell(s) in loadedShipsTable.
function loadedShipsTable_CellEditCallback(hObject, eventdata, handles)
    % hObject    handle to loadedShipsTable (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
    %	Indices: row and column indices of the cell(s) edited
    %	PreviousData: previous data for the cell(s) edited
    %	EditData: string(s) entered by the user
    %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
    %	Error: error string when failed to convert EditData to appropriate value for Data
    % handles    structure with handles and user data (see GUIDATA)
    loadedShips = getappdata(handles.mainGUI,'loadedShips');
    row = eventdata.Indices(1);
    ship = loadedShips{row};
    
    if(eventdata.Indices(2) == 2)
        ship.team = NNS_ShipTeam.getTeamForStr(eventdata.NewData);
    end
