classdef NNS_BasicShipController < NNS_AbstractShipController & NNS_AbstractPoweredComponent
    %NNS_BasicShipController Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship@NNS_PropagatedObject
        allSubroutines@NNS_ControllerSubroutine
        
        variables(1,1) NNS_ControllerVariableList
        
        id@double
        relPos@double = [0;0]         % m - relative to the origin of vessel it's mounted on
    end
    
    properties(Constant)
        typeName@char = 'Ship Controller';
    end
    
    methods
        function obj = NNS_BasicShipController(ship)
            obj.ship = ship;
            obj.id = rand();
            obj.allSubroutines = NNS_ControllerSubroutine.empty(0,0);
            obj.variables = NNS_ControllerVariableList(); 
            
            obj.drawer = NNS_BasicShipControllerDrawer(ship, obj);
        end
        
        function initializeComponent(obj)
            allSubs = obj.getAllSubroutines();
            for(i=1:length(allSubs)) %#ok<*NO4LP>
                allSubs(i).initializeComponent();
            end
        end
        
        function executeNextOperation(obj)
            obj.allSubroutines(1).executeNextOp();
        end
        
        function subroutine = getSubroutineForIndex(obj,ind)
            subroutine = obj.allSubroutines(ind);
        end
        
        function subroutines = getAllSubroutines(obj)
            subroutines = obj.allSubroutines;
        end

        function mainSubR = getMainSubroutine(obj)
            mainSubR = obj.getSubroutineForIndex(1);
        end
        
        function newInd = addSubroutine(obj,newSr)
            obj.allSubroutines(end+1) = newSr;
            newInd = length(obj.allSubroutines);
        end
        
        function removeSubroutine(obj,subR)
            obj.allSubroutines(obj.allSubroutines == subR) = [];
        end
        
        function ind = getControllerInd(obj)
            cntrlrComps = obj.ship.components.getControllerComps();
            ind = find(cntrlrComps == obj,1,'first');
        end
        
        function str = getShortCompName(obj)
            ind = obj.getControllerInd();
            str = sprintf('Ctr[%i]',ind);
        end
        
        function vars = getVariableList(obj)
            vars = obj.variables;
        end
        
        function mass = getMass(obj)
            mass = 300*(pi*obj.getCompRadiusForPower()^2);
        end
        
        function charSize = getCharacteristicSizeForComp(obj)
            charSize = obj.getCompRadiusForPower();
        end

        function drawObjectOnAxes(obj, hAxes)
            if(isempty(obj.drawer))
                obj.drawer = NNS_BasicShipControllerDrawer(obj.ship, obj);
            end
            
            if(isempty(obj.drawer.ship))
                obj.drawer.ship = obj.ship;
            end
            
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
        
        function str = getInfoStrForComponent(obj)
            str = {};
            
            str{end+1} = sprintf('%s %10.3f W',       paddStr('Power Used         =', 25), abs(obj.getPowerDrawGen()));
            str{end+1} = sprintf('%s %10.3f m',       paddStr('Radius             =', 25), obj.getCompRadiusForPower());
            str{end+1} = sprintf('%s %10.3f kg',      paddStr('Mass               =', 25), obj.getMass());
            str{end+1} = sprintf('%s [%.2f, %.2f] m', paddStr('Position (X,Y)     =', 25), obj.relPos(1), obj.relPos(2));
        end
        
        function hFig = createCompPropertiesEditorFigure(obj, handlesForShipCompEditUI)
            handles = handlesForShipCompEditUI;
            
            set(handles.shipCompEditorGUI,'Visible','off');
            obj.ship = shipProgramEditorGUI(obj.ship, obj);
            set(handles.shipCompEditorGUI,'Visible','on');

            setappdata(handles.shipCompEditorGUI,'ship',obj.ship);
        end
        
        function power = getPowerDrawGen(obj)
            power = -1000;
        end
        
        function radius = getCompRadiusForPower(obj)
            radius = 0.25;
        end
    end
    
    methods(Static)
        function basicCntrlr = getDefaultBasicController(ship)
            basicCntrlr = NNS_BasicShipController(ship);
            sr = NNS_ControllerSubroutine.getDefaultSubroutine(ship);
            sr.name = 'Main';
            basicCntrlr.addSubroutine(sr);
        end
    end
end

