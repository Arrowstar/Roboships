classdef NNS_BasicShipHull < NNS_AbstractHull
    %NNS_BasicShipHull Summary of this class goes here
    
    properties
        ship@NNS_PropagatedObject
        relPos@double  = [0;0];
        
        curHitPts@double
        
        drawer@NNS_AbstractPropagatedObjectDrawer
        id@double
    end
    
    properties(SetObservable)
        hullVerts@double
        hullThickness@double %millimeters
    end
    
    properties(Constant)
        typeName@char = 'Basic Ship Hull';
        minHullThickness = 1; %mm
        maxHullThickness = 100; %mm
    end
    
    properties(Access=private)
        mass@double = [];
        momInert@double = [];
        frontArea@double = [];
        sideArea@double = [];
    end
    
    methods
        function obj = NNS_BasicShipHull(hullThickness, hullVerts, ship)
            %NNS_BasicShipHull Construct an instance of this class
            obj.ship = ship;
            obj.hullVerts = hullVerts;
            obj.hullVerts = obj.rotateHullVertsAndTranslateCentroidToOrigin(-90);
            obj.hullThickness = hullThickness;

            obj.curHitPts = obj.getMaxHitPoints();
            
            obj.id = rand();
            obj.drawer = NNS_BasicShipHullDrawer(ship, obj);
            
            addlistener(obj,'hullVerts','PreSet', @(src,evt) obj.clearCachedValues(src, evt));
        end
        
        function newVerts = rotateHullVertsAndTranslateCentroidToOrigin(obj, rotAngleDeg)
            pgon = polyshape(obj.hullVerts);
            [cx,cy] = centroid(pgon);
            pgon.Vertices = pgon.Vertices - [cx,cy];
            pgon = rotate(pgon,rotAngleDeg,[0,0]);
            
            newVerts = pgon.Vertices;
        end
        
        function initializeComponent(obj)
            obj.curHitPts = obj.getMaxHitPoints();
        end
        
        function copiedComp = copy(obj)
            copiedComp = obj.createDefaultBasicShipHull(obj.ship);
            copiedComp.hullVerts = obj.hullVerts;
            copiedComp.hullThickness = obj.hullThickness;
            
            obj.ship.components.addComponent(copiedComp);
        end
        
        function set.hullThickness(obj,newHullThickness)
            obj.hullThickness = newHullThickness;
            obj.mass = []; %#ok<MCSUP>
            obj.curHitPts = obj.getMaxHitPoints(); %#ok<MCSUP>
        end
        
        function set.mass(obj, newMass)
            obj.mass = newMass;
        end
        
        function massR = getMass(obj)
            if(isempty(obj.mass))
                densityAl = 2700; %kg/m^3
                thickness = (obj.hullThickness/1000); %m
                
                if(not(isempty(obj.hullVerts)))
                    pgon = polyshape(obj.hullVerts(:,1), obj.hullVerts(:,2));
                    obj.mass = densityAl * (pgon.area() + pgon.perimeter()*1) * thickness;
                else
                    obj.mass = 0;
                end
            end
            
            massR = obj.mass;
        end
        
        function momInertR = getMomentOfInertia(obj)           
            if(isempty(obj.momInert))
                Lx = max(obj.hullVerts(:,1)) - min(obj.hullVerts(:,1));
                Ly = max(obj.hullVerts(:,2)) - min(obj.hullVerts(:,2));
                L = max([Lx,Ly]);
                
                obj.momInert = (1/3)*obj.getMass()*L^2;
            end
            
            momInertR = obj.momInert;
        end
        
        function frontAreaR = getFrontalSurfArea(obj)
            if(isempty(obj.frontArea))
                obj.frontArea = max(obj.hullVerts(:,1)) - min(obj.hullVerts(:,1));
            end
            
            frontAreaR = obj.frontArea;
        end
        
        function sideAreaR = getSideSurfArea(obj)
            if(isempty(obj.sideArea))
                obj.sideArea = max(obj.hullVerts(:,2)) - min(obj.hullVerts(:,2));
            end
            
            sideAreaR = obj.sideArea;
        end

        function CdL = getLinearDragCoeff(obj)
            CdL = 0.05;
        end
        
        function CdR = getRotDragCoeff(obj)
            CdR = 0.05;
        end
        
        function CdA = getLinearCdA(obj)
            CdA = obj.getLinearDragCoeff() * obj.getFrontalSurfArea();
        end
        
        function CdA = getRotCdA(obj)
            CdA = obj.getRotDragCoeff() * obj.getSideSurfArea();
        end
        
        function hullVerts = getHullVertices(obj)
            hullVerts = obj.hullVerts;
        end
        
        function maxHitPoints = getMaxHitPoints(obj)
            maxHitPoints = ceil(obj.getMass());
        end
        
        function curHitPoints = getCurHitPoints(obj)
            curHitPoints = obj.curHitPts;
        end
        
        function takeDamage(obj, damagePts)
            obj.curHitPts = obj.curHitPts - damagePts;
        end
        
        function charSize = getCharacteristicSizeForComp(obj)
            charSize = polyarea(obj.hullVerts(:,1),obj.hullVerts(:,2));
        end
        
        function drawObjectOnAxes(obj, hAxes)
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
        
        function str = getInfoStrForComponent(obj)
            engine = obj.ship.components.engComps(1);
            rudder = obj.ship.components.rudComps(1);
            
            str = {};
            str{end+1} = sprintf('%s %10.0f',      paddStr('Total Hit Points  =', 25), obj.getMaxHitPoints());
            str{end+1} = sprintf('%s %10.1f mm',   paddStr('Hull Thickness    =', 25), obj.hullThickness);
            str{end+1} = sprintf('%s %10.3f m^3',  paddStr('Hull Area         =', 25), polyarea(obj.hullVerts(:,1), obj.hullVerts(:,2)));
            str{end+1} = sprintf('%s %10.3f kg',   paddStr('Mass              =', 25), obj.getMass());
            str{end+1} = getShipCompEditorRightHRule();
            str{end+1} = sprintf('%s %10.3f W',    paddStr('Engine Power Used =', 25), abs(engine.getPowerDrawGen()));
            str{end+1} = sprintf('%s %10.3f W',    paddStr('Rudder Power Used =', 25), abs(rudder.getPowerDrawGen()));
        end
        
        function hFig = createCompPropertiesEditorFigure(obj, handlesForShipCompEditUI)
            fH = @(src,evt) obj.compUpdated(src,evt, handlesForShipCompEditUI);
            
            hullThicknessL = addlistener(obj,'hullThickness','PostSet',fH);
            
            engine = obj.ship.components.engComps(1);
            engL = addlistener(engine,'maxThrust','PostSet',fH);
            
            rudder = obj.ship.components.rudComps(1);
            rudL = addlistener(rudder,'maxTorque','PostSet',fH);
            
            hFig = basicHullEngineRudderEditorGUI(obj.ship);
            hFig.CloseRequestFcn = @(src, evt) obj.hullEditorCloseReqFunc(src, evt, hullThicknessL, engL, rudL);
        end
        
        function clearCachedValues(obj, ~, ~)
            obj.mass = [];
            obj.momInert = [];
            obj.frontArea = [];
            obj.sideArea = [];
        end
        
        function str = getShortCompName(obj)
            str = 'Hull';
        end
    end
    
    methods(Static)
        function hull = createDefaultBasicShipHull(ship)
            hullVerts = [-1 0; 1 0; 1 3; 0 4; -1 3];
            hullVerts(:,2) = hullVerts(:,2) - 2.5;
                       
            hull = NNS_BasicShipHull(30, hullVerts, ship);
        end        
        
        function compUpdated(~,~,handles)
            updateDataDisplays(handles);
        end
        
        function hullEditorCloseReqFunc(src, ~, hullThicknessL, engL, rudL)
            delete(hullThicknessL);
            delete(engL);
            delete(rudL);
            delete(src);
        end
    end
end

