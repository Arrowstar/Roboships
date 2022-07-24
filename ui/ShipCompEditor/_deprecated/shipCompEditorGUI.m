function varargout = shipCompEditorGUI(varargin)
    % SHIPCOMPEDITORGUI MATLAB code for shipCompEditorGUI.fig
    %      SHIPCOMPEDITORGUI, by itself, creates a new SHIPCOMPEDITORGUI or raises the existing
    %      singleton*.
    %
    %      H = SHIPCOMPEDITORGUI returns the handle to a new SHIPCOMPEDITORGUI or the handle to
    %      the existing singleton*.
    %
    %      SHIPCOMPEDITORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in SHIPCOMPEDITORGUI.M with the given input arguments.
    %
    %      SHIPCOMPEDITORGUI('Property','Value',...) creates a new SHIPCOMPEDITORGUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before shipCompEditorGUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to shipCompEditorGUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help shipCompEditorGUI
    
    % Last Modified by GUIDE v2.5 06-Aug-2018 19:19:12
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @shipCompEditorGUI_OpeningFcn, ...
        'gui_OutputFcn',  @shipCompEditorGUI_OutputFcn, ...
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
    
    
    % --- Executes just before shipCompEditorGUI is made visible.
function shipCompEditorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to shipCompEditorGUI (see VARARGIN)
    
    % Choose default command line output for shipCompEditorGUI
    handles.output = hObject;
    
    if(numel(varargin) >= 1)
        ship = varargin{1};
    else
        arena = NNS_Arena([-25 25], [-25 25]);
        ship = NNS_Ship.createDefaultBasicShip(arena);
    end
    ship.active = true;
    setappdata(hObject,'ship',ship);
    
    shpGrp = ShipGraphicalObjects();
    setappdata(hObject,'shipGraphics',shpGrp);
    setappdata(hObject,'intersectionExceptions',NNS_ComponentIntersectionExceptionSet.getDefaultComponentIntersectionExceptionSet());
    
    handles = setupGUI(ship, shpGrp, handles);
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes shipCompEditorGUI wait for user response (see UIRESUME)
    uiwait(handles.shipCompEditorGUI);
    
function handles = setupGUI(ship, shpGrp, handles)
    createDefaultSPoly(shpGrp, ship, handles);
    shpGrp.sPoly.setPosition(ship.hull.hullVerts);
    
    updateVehDynSumText(ship, handles);
    updateVehPowerSumText(ship, handles);
    selectComponent([], ship, handles);
    
    el = addlistener(ship.hull,'hullVerts','PostSet', @(src,evt) shipCompEdit_HullVertsUpdated(src, evt, ship, handles));
    shpGrp.els(end+1) = el;
    
    cH = NNS_ComponentHierarchy.getDefaultComponentHierarchy();
    setappdata(handles.shipCompEditorGUI,'CompHier',cH);
    set(handles.compListbox,'String',cH.getListboxStr());
    
    for(i=1:length(ship.components.components))
        c = ship.components.components(i);
        if(isa(c,'NNS_AbstractDrawableVehicleComponent') && not(isa(c,'NNS_AbstractHull')))
            createCPolyForComp(c, shpGrp, ship, handles);
        end
    end
    
    sortAxes2dImpolyChildren(handles.shipCanvasAxes);
    
    intersectionExceptions = getappdata(handles.shipCompEditorGUI,'intersectionExceptions');
    updateCPolyEdgesBasedOnValidness(shpGrp, intersectionExceptions);
    
    handles.textBoxTooltip = annotation('textbox', 'Visible','off', 'Interpreter','none',...
                                        'BackgroundColor',[255,255,224]/255, 'Margin',0, ...
                                        'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
                                        'HitTest','off', 'PickableParts','none');
    
    
function createDefaultSPoly(shpGrp, ship, handles)
    initShipPos = [-1 0; 1 0; 1 3; 0 4; -1 3];
    initShipPos = initShipPos - ShipGraphicalObjects.getCentroidOfVertices(initShipPos);
    fh = makeConstrainToRectFcn('impoly',get(handles.shipCanvasAxes,'XLim'),get(handles.shipCanvasAxes,'YLim'));
    
    sPoly = impoly(handles.shipCanvasAxes,initShipPos,'Closed',true,'PositionConstraintFcn',@(p) polyPosConstraintFunc(p, fh));
    sPoly.setPosition(polyPosConstraintFunc(sPoly.getPosition(), fh));
    sPoly.Deletable = false;
    sPoly.setColor('k');
    
    pp = findall(sPoly,'Type','patch');
    pp = pp(1);
    pp.FaceColor = [211,211,211]/255;
    pp.FaceAlpha = 0.75;
    pp.EdgeColor = 'k';
    
    shpGrp.setSPoly(sPoly);
    sPoly.addNewPositionCallback(@(p) moveShipComps(p, shpGrp, handles));
    sPoly.addNewPositionCallback(@(p) updateShipHullVerts(p, ship.hull));
    
    %delete built in context menu
    c = get(sPoly,'Children');
    cm = uicontextmenu(handles.shipCanvasAxes.Parent);
    cmenu_obj = findobj(c,'Type','line','-or','Type','patch');
    set(cmenu_obj,'uicontextmenu',cm);
    
    
    % --- Outputs from this function are returned to the command line.
function varargout = shipCompEditorGUI_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = getappdata(hObject,'ship');
    delete(hObject);
    
    
    % --- Executes during object creation, after setting all properties.
function shipCanvasAxes_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to shipCanvasAxes (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: place code in OpeningFcn to populate shipCanvasAxes
    hObject.XLimMode = 'manual';
    hObject.XLim = [-5 5];
    hObject.XTick = [hObject.XLim(1):hObject.XLim(2)]; %#ok<NBRAK>
    hObject.YLimMode = 'manual';
    hObject.YLim = [-5 5];
    hObject.YTick = [hObject.YLim(1):hObject.YLim(2)]; %#ok<NBRAK>
    hObject.XTickLabel = {};
    hObject.YTickLabel = {};
    grid(hObject,'on');
    grid(hObject,'minor');
    
    
function newPos = polyPosConstraintFunc(pos, fhAxesLimit)
    newPos = fhAxesLimit(pos);
    %     newPos = round(newPos,1);
    
    
function moveShipComps(pos,shpGrp,handles)
    [cx,cy]=centroid(polyshape(pos));
    [ocx, ocy] = centroid(polyshape(shpGrp.oldPos));
    
    deltaPos = [cx,cy] - [ocx, ocy];
    
    if(size(pos) == size(shpGrp.oldPos))
        if(sum(any(abs(pos - shpGrp.oldPos) > 0,2)) > 1) %we are translating the ship, not moving a vertex
            for(i=1:length(shpGrp.cPolys)) %#ok<*NO4LP>
                if(isvalid(shpGrp.cPolys(i)))
                    curCPos = shpGrp.cPolys(i).getPosition();
                    if(any(inpolygon(curCPos(:,1),curCPos(:,2), shpGrp.oldPos(:,1), shpGrp.oldPos(:,2))==1)) %only move if at least some of the component is inside the ship.
                        shpGrp.cPolys(i).setPosition(curCPos + deltaPos);
                    end
                end
            end
        end
        
        for(i=1:length(shpGrp.cPolys))
            compMovedCallback(shpGrp.cPolys(i).getPosition(), shpGrp.cPolys(i), shpGrp, handles);
        end
    end
    
    shpGrp.oldPos = pos;
    
    
function updateShipHullVerts(pos, hull)
    hull.hullVerts = pos;
    
    % --- Executes on selection change in compListbox.
function compListbox_Callback(hObject, eventdata, handles)
    % hObject    handle to compListbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns compListbox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from compListbox
    if(strcmpi(handles.shipCompEditorGUI.SelectionType,'open'))
        contents = cellstr(get(hObject,'String'));
        sel = strip(contents{get(hObject,'Value')});
        
        shpGrp = getappdata(handles.shipCompEditorGUI,'shipGraphics');
        ship = getappdata(handles.shipCompEditorGUI,'ship');
        
        newComp = NNS_ComponentHierarchy.getDefaultComponentForTypeName(sel, ship);
        if(not(isempty(newComp)))
            addVehCompToShip(newComp, ship, shpGrp, handles);
            
            intersectionExceptions = getappdata(handles.shipCompEditorGUI,'intersectionExceptions');
            updateCPolyEdgesBasedOnValidness(shpGrp, intersectionExceptions);
        end
    end
    
    
function addVehCompToShip(newComp, ship, shpGrp, handles)
    ship.components.addComponent(newComp);
    createCPolyForComp(newComp, shpGrp, ship, handles);
    
    updateVehDynSumText(ship, handles);
    updateVehPowerSumText(ship, handles);
    
    
function createCPolyForComp(c, shpGrp, ship, handles)
    c.drawObjectOnAxes(handles.shipCanvasAxes);
    patch = c.drawer.getPatchForDrawnComponents();
    
    cPoly = getNewCPolyForShipCanvass(patch.Vertices+shpGrp.getSpolyCentroid()+c.relPos', shpGrp, ship, handles);
    shpGrp.addCpoly(cPoly,c);
    cPChildren = get(cPoly,'Children');
    pp = cPChildren(end);
    pp.FaceColor = patch.FaceColor;
    pp.EdgeColor = patch.EdgeColor;
    
    c.destroyGraphics();
    el = addlistener(c,'ShipEditorCompNeedsRedraw', @(src,evt) replaceCPolyForEventCallback(src,evt, shpGrp, handles));
    shpGrp.els(end+1) = el;
    
    
function cPoly = getNewCPolyForShipCanvass(vertices, shpGrp, ship, handles)
    fh = makeConstrainToRectFcn('impoly',get(handles.shipCanvasAxes,'XLim'),get(handles.shipCanvasAxes,'YLim'));
    cPoly = impoly(handles.shipCanvasAxes,vertices,'Closed',true,'PositionConstraintFcn',@(p) cPolyPosConstraintFunc(p, fh));
    cPoly.setVerticesDraggable(false);
    cPoly.setColor('k');
    cPoly.addNewPositionCallback(@(p) compMovedCallback(p, cPoly, shpGrp, handles));
    
    el = addlistener(cPoly,'ObjectBeingDestroyed',@(x1,x2) removeCPolyFromGraphics(x1,x2, shpGrp, ship, handles));
    shpGrp.els(end+1) = el;
    
    pp = findall(cPoly,'Type','patch');
    pp = pp(1);
    pp.FaceColor = 'g';
    pp.EdgeColor = 'k';
    
    pl = findall(cPoly,'Type','line');
    for(i=1:length(pl))
        pl(i).Visible = 'off';
    end
    
    sortAxes2dImpolyChildren(handles.shipCanvasAxes);
    
    %delete built in context menu
    c = get(cPoly,'Children');
    cm = uicontextmenu(handles.shipCanvasAxes.Parent);
    cmenu_obj = findobj(c,'Type','line','-or','Type','patch');
    set(cmenu_obj,'uicontextmenu',cm);
    
    
function replaceCPolyForComp(c, shpGrp, handles)
    c.drawObjectOnAxes(handles.shipCanvasAxes);
    patch = c.drawer.getPatchForDrawnComponents();
    
    cPoly = shpGrp.cPolyCompRefs.getCPolyForComp(c);
    oldPos = shpGrp.getCentroidOfImpoly(cPoly);
    newPos = shpGrp.getCentroidOfVertices(patch.Vertices);
    
    deltaPos = newPos - oldPos;
    cPoly.setPosition(patch.Vertices - deltaPos);
    
    c.destroyGraphics();
    
    
function replaceCPolyForEventCallback(src,~, shpGrp, handles)
    replaceCPolyForComp(src, shpGrp, handles);
    
    
function removeCPolyFromGraphics(cPoly,~, shpGrp, ship, handles)
    c = shpGrp.cPolyCompRefs.getCompForCpoly(cPoly);
    ship.components.removeComponent(c);
    shpGrp.removeCpoly(cPoly);
    delete(cPoly);
    
    updateVehDynSumText(ship, handles);
    updateVehPowerSumText(ship, handles);
    selectComponent([], ship, handles);
    
    
function newPos = cPolyPosConstraintFunc(pos, fhAxLimits)
    pos = fhAxLimits(pos);
    c = ShipGraphicalObjects.getCentroidOfVertices(pos);
    cRounded = round(c,1);
    deltaPos = cRounded - c;
    
    newPos = pos - deltaPos;
    
    
    % --- Executes during object creation, after setting all properties.
function compListbox_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to compListbox (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
function isValid = validateCompPosition(curCPos, cPoly, shpGrp, intersectionExceptions)
    curSPos = shpGrp.sPoly.getPosition();
    inShipEdge = inpolygon(curCPos(:,1),curCPos(:,2),curSPos(:,1),curSPos(:,2));
    
    inOtherComp = [];
    cPolys = shpGrp.cPolys;
    for(i=1:length(cPolys))
        oCpoly = cPolys(i);
        
        if(not(cPoly == oCpoly))
            oPos = oCpoly.getPosition();
            
            comp1 = shpGrp.cPolyCompRefs.getCompForCpoly(cPoly);
            comp2 = shpGrp.cPolyCompRefs.getCompForCpoly(oCpoly);
            
            if(not(intersectionExceptions.hasIntersectionException(comp1, comp2)))
                inOtherComp = [inOtherComp; inpolygon(curCPos(:,1),curCPos(:,2),oPos(:,1),oPos(:,2))]; %#ok<AGROW>
            end
        end
    end
    
    if(all(inShipEdge) && all(inOtherComp == 0))
        isValid = true;
    else
        isValid = false;
    end
    
function updateCPolyEdgesBasedOnValidness(shpGrp, intersectionExceptions)
    cPolys = shpGrp.cPolys;
    for(i=1:length(cPolys))
        cPoly = cPolys(i);
        
        isValid = validateCompPosition(cPoly.getPosition(), cPoly, shpGrp, intersectionExceptions);
        
        pp = findall(cPoly,'Type','patch');
        pp = pp(1);
        if(isValid)
            pp.EdgeColor = 'k';
        else
            pp.EdgeColor = 'r';
        end
    end
    
    
function compMovedCallback(~, curCPoly, shpGrp, handles)
    intersectionExceptions = getappdata(handles.shipCompEditorGUI,'intersectionExceptions');
    
    comp = shpGrp.cPolyCompRefs.getCompForCpoly(curCPoly);
    comp.relPos = (shpGrp.getCentroidOfImpoly(curCPoly) - shpGrp.getSpolyCentroid())';
    
    updateCPolyEdgesBasedOnValidness(shpGrp, intersectionExceptions);
    
    sortAxes2dImpolyChildren(handles.shipCanvasAxes);
    updateDataDisplays(handles);
    
    % --- Executes on button press in saveAndCloseButton.
function saveAndCloseButton_Callback(hObject, eventdata, handles)
    % hObject    handle to saveAndCloseButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    close(handles.shipCompEditorGUI);
    
    
    % --- Executes on button press in editSelCompButton.
function editSelCompButton_Callback(hObject, eventdata, handles)
    % hObject    handle to editSelCompButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    selComp = getappdata(handles.shipCompEditorGUI,'selectedComponent');
    selComp.createCompPropertiesEditorFigure(handles);
    
    
    % --- Executes on mouse press over figure background, over a disabled or
    % --- inactive control, or over an axes background.
function shipCompEditorGUI_WindowButtonDownFcn(hObject, eventdata, handles)
    % hObject    handle to shipCompEditorGUI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    shpGrp = getappdata(handles.shipCompEditorGUI,'shipGraphics');
    ship = getappdata(handles.shipCompEditorGUI,'ship');
    
    cp = get(handles.shipCanvasAxes, 'CurrentPoint');
    cp = cp(1,1:2);
    
    poly = shpGrp.getPolyForPoint(cp);
    selComp = shpGrp.selectPoly(poly);
    
    selectComponent(selComp, ship, handles);
    
function selectComponent(selComp, ship, handles)
    if(isempty(selComp))
        selComp = ship.hull;
    end
    
    setappdata(handles.shipCompEditorGUI,'selectedComponent',selComp);
    updateDataDisplays(handles);
    
    
    % --- Executes on key press with focus on shipCompEditorGUI or any of its controls.
function shipCompEditorGUI_WindowKeyPressFcn(hObject, eventdata, handles)
    % hObject    handle to shipCompEditorGUI (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
    %	Key: name of the key that was pressed, in lower case
    %	Character: character interpretation of the key(s) that was pressed
    %	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
    % handles    structure with handles and user data (see GUIDATA)
    shpGrp = getappdata(handles.shipCompEditorGUI,'shipGraphics');
    selComp = getappdata(handles.shipCompEditorGUI,'selectedComponent');
    ship = getappdata(handles.shipCompEditorGUI,'ship');
    
    if(not(isempty(selComp)))
        if(isa(selComp,'NNS_AbstractHull'))
            poly = shpGrp.sPoly;
        else
            poly = shpGrp.cPolyCompRefs.getCPolyForComp(selComp);
        end
        oldPos = poly.getPosition();
        
        newPos = [];
        switch eventdata.Key
            case 'rightarrow'
                tfm = [0.01,0];
                newPos = oldPos + tfm;
            case 'leftarrow'
                tfm = [-0.01,0];
                newPos = oldPos + tfm;
            case 'uparrow'
                tfm = [0,0.01];
                newPos = oldPos + tfm;
            case 'downarrow'
                tfm = [0,-0.01];
                newPos = oldPos + tfm;
            case 'c'
                if(ismember('control',eventdata.Modifier))
                    try
                        if(not(isa(selComp,'NNS_AbstractHull')) && isa(selComp,'NNS_VehicleComponent'))
                            copiedComp = selComp.copy();
                            copiedComp.relPos = [0;0];
                            addVehCompToShip(copiedComp, ship, shpGrp, handles);
                        end
                    catch ME
                        warndlg('The selected ship component could not be copied.');
                    end
                end
            case 'delete'
                if(poly.Deletable)
                    controllers = ship.components.getControllerComps();
                    
                    allSubs = NNS_ControllerSubroutine.empty(0,0);
                    for(i=1:length(controllers))
                        controller = controllers(i);
                        allSubs = horzcat(allSubs, controller.getAllSubroutines()); %#ok<AGROW>
                    end
                    
                    inUse = false;
                    for(i=1:length(allSubs))
                        sub = allSubs(i);
                        
                        for(j=1:length(sub.operations))
                            op = sub.operations(j);
                            
                            comp = op.getComponent();
                            if(isa(comp,'NNS_Ship'))
                                comp = comp.hull;
                            end
                            
                            if(selComp == comp)
                                inUse = true;
                                break;
                            end
                            
                            numerics = op.getNumeric();
                            if(not(isempty(numerics)))
                                for(k=1:length(numerics))
                                    numeric = numerics(k);
                                    
                                    if(isa(numeric,'NNS_ControllerComponentParameter'))
                                        numericComp = numeric.getComponent();
                                        
                                        if(selComp == numericComp)
                                            inUse = true;
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if(inUse == false)
                        delete(poly);
                        
                        intersectionExceptions = getappdata(handles.shipCompEditorGUI,'intersectionExceptions');
                        updateCPolyEdgesBasedOnValidness(shpGrp, intersectionExceptions)
                    else
                        warndlg('A component cannot be deleted if it is in use in a operation or conditional block or parameter in a subroutine.','Cannot Delete Variable','modal');
                    end
                end
        end
        
        if(not(isempty(newPos)))
            poly.setPosition(newPos);
        end
        
        updateDataDisplays(handles);
    end
    
    
    % --- Executes when user attempts to close shipCompEditorGUI.
function shipCompEditorGUI_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to shipCompEditorGUI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: delete(hObject) closes the figure
    shpGrp = getappdata(handles.shipCompEditorGUI,'shipGraphics');
    intersectionExceptions = getappdata(handles.shipCompEditorGUI,'intersectionExceptions');
    
    cPolys = shpGrp.cPolys;
    isValidArr = ones([length(cPolys),1]);
    problemComps = {};
    for(i=1:length(cPolys))
        cPoly = cPolys(i);
        
        isValidArr(i) = validateCompPosition(cPoly.getPosition(), cPoly, shpGrp, intersectionExceptions);
        
        if(isValidArr(i) == 0)
            problemComps(end+1) = {shpGrp.cPolyCompRefs.getCompForCpoly(cPoly).getShortCompName()}; %#ok<AGROW>
        end
    end
    
    if(all(isValidArr))
        shpGrp.destroyAllListeners();
        uiresume(hObject);
    else
        warnMsg = sprintf('The following components are in error because they are either outside the bounds of the ship or conflict with another component.  You must correct these errors before returning to the main menu.\n\n');
        for(i=1:length(problemComps))
            warnMsg = [warnMsg, sprintf('\t%s\n', problemComps{i})]; %#ok<AGROW>
        end
        warndlg(warnMsg);
    end
    
    
    % --------------------------------------------------------------------
function setShipNameAndDesc_Callback(hObject, eventdata, handles)
    % hObject    handle to setShipNameAndDesc (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    ship = getappdata(handles.shipCompEditorGUI,'ship');
    
    prompt = {'Enter the ship name:', 'Enter the ship description:'};
    dlg_title = 'Ship Information';
    num_lines = [1, 50;
        10, 50];
    defAns = {ship.name, ship.desc};
    
    answer = inputdlg(prompt,dlg_title,num_lines,defAns);
    
    ship.name = answer{1};
    ship.desc = answer{2};
    
    
    % --- Executes on button press in editPidControllersButton.
function editPidControllersButton_Callback(hObject, eventdata, handles)
    % hObject    handle to editPidControllersButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    ship = getappdata(handles.shipCompEditorGUI,'ship');
    editShipPidControllersGUI(ship);
    
    
    % --- Executes on mouse motion over figure - except title and menu.
function shipCompEditorGUI_WindowButtonMotionFcn(hObject, eventdata, handles)
    % hObject    handle to shipCompEditorGUI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    shpGrp = getappdata(handles.shipCompEditorGUI,'shipGraphics');
%     ship = getappdata(handles.shipCompEditorGUI,'ship');
    
    C = get(handles.shipCanvasAxes, 'CurrentPoint');
    cX = C(1,1);
    cY = C(1,2);
    
    cPolys = shpGrp.cPolys;
    hObj = hittest(handles.shipCompEditorGUI);
    if(isa(hObj,'matlab.graphics.primitive.Patch'))        
        [Xf, Yf] = ds2nfu(handles.shipCanvasAxes, cX, cY);
        tttPos = handles.textBoxTooltip.Position;
        
        newPos = [Xf, Yf];
        if(cX > 0)
            newPos(1) = Xf - tttPos(3);
        end
        
        if(cY > 0)
            newPos(2) = Yf - tttPos(4);
        end
        
        tttPos(1:2) = newPos;
        handles.textBoxTooltip.Position = tttPos;
        
        comp = shpGrp.cPolyCompRefs.getCompForCpoly(shpGrp.getPolyForPoint([cX,cY]));
        if(not(isempty(comp)))
            str = comp.getShortCompName();
            if(not(isempty(str)))
                handles.textBoxTooltip.String = sprintf('%s (%s)', comp.typeName, str);
                handles.textBoxTooltip.Visible = 'on';
            else
                handles.textBoxTooltip.Visible = 'off';
            end
        else
            handles.textBoxTooltip.Visible = 'off';
        end
    else
        handles.textBoxTooltip.Visible = 'off';
    end
    
