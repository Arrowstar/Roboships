classdef NNS_BasicActiveSensor < NNS_AbstractSensor & NNS_AbstractPointableComponent & NNS_AbstractPoweredComponent
    %NNS_BasicActiveSensor Summary of this class goes here
       
    properties
        drawer NNS_AbstractPropagatedObjectDrawer
        
        filter NNS_AbstractSensorFilter
        ship
        
        %utilty
        isaDetectable function_handle;
        lastSensorOutput NNS_SensorOutput
        id double
    end
    
    properties(Dependent)
        propObjs NNS_PropagatedObjectList
    end
    
    properties(SetObservable) 
        curConeAngle double
        
        maxRng double             = 25; % m
        maxConeAngle double
        threeSigRngDevPercent double         %0 -> 1.0
        threeSigAngDevPercent double         %0 -> 1.0

        relPos double  = [0;0];         % m - relative to the origin of vessel it's mounted on
    end
    
    properties(Constant)
        typeName char = 'Basic Active Radar';
        
        maxAllowableMaxRange double = 50;
        maxAllowableMaxConeAngle double = deg2rad(180);
        maxAllowableThreeSigRngDevPercent double = 0.1;
        maxAllowableThreeSigAngDevPercent double = 0.1;
    end
    
    methods
        function obj = NNS_BasicActiveSensor(maxRng, maxConeAngle, threeSigRngDevPercent, threeSigAngDevPercent, relPos, ship)
            %NNS_BasicActiveSensor Construct an instance of this class
            obj.maxRng = maxRng;
            obj.maxConeAngle = deg2rad(maxConeAngle);
            obj.curConeAngle = obj.maxConeAngle;
            obj.threeSigRngDevPercent = threeSigRngDevPercent;
            obj.threeSigAngDevPercent = threeSigAngDevPercent;
            obj.relPos  = relPos;
            obj.drawer  = NNS_BasicActiveSensorDrawer(ship, obj);
            obj.ship = ship;
            obj.filter = NNS_EnemyShipsSensorFilter(obj);
            
            obj.isaDetectable = @(x) isa(x, 'NNS_IsDetectable') & x~=obj.ship;
            
            obj.lastSensorOutput = NNS_SensorOutput.empty(0,0);
            
            obj.id = rand();
        end
        
        function initializeComponent(obj)
            obj.curConeAngle = obj.maxConeAngle;
            obj.lastSensorOutput = NNS_SensorOutput.empty(0,0);
            obj.destroyGraphics();
        end
        
        function copiedComp = copy(obj)
            copiedComp = obj.getDefaultBasicActiveSensor(obj.ship);
            copiedComp.filter = obj.filter;
            copiedComp.curConeAngle = obj.curConeAngle;
            copiedComp.maxRng = obj.maxRng;
            copiedComp.maxConeAngle = obj.maxConeAngle;
            copiedComp.threeSigRngDevPercent = obj.threeSigRngDevPercent;
            copiedComp.threeSigAngDevPercent = obj.threeSigAngDevPercent;
            
            obj.ship.components.addComponent(copiedComp);
        end   
        
        function mass = getMass(obj)
            mass = 300*(pi*obj.getCompRadiusForPower()^2);
        end
        
        function propObjs = get.propObjs(obj)
            propObjs = obj.ship.arena.propObjs;
        end
        
        function curConeAngle = get.curConeAngle(obj)
            if(obj.curConeAngle > obj.maxConeAngle)
                obj.curConeAngle = obj.maxConeAngle;
            end
            curConeAngle = obj.curConeAngle;
        end
        
        function set.curConeAngle(obj, newCurConeAngle)
            if(newCurConeAngle > obj.maxConeAngle) %#ok<MCSUP>
                newCurConeAngle = obj.maxConeAngle; %#ok<MCSUP>
            end
            obj.curConeAngle = newCurConeAngle;
        end

        function set.maxRng(obj, maxRng)
            obj.maxRng = maxRng;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
        
        function set.maxConeAngle(obj, maxConeAngle)
            obj.maxConeAngle = maxConeAngle;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
        
        function set.threeSigRngDevPercent(obj, threeSigRngDevPercent)
            obj.threeSigRngDevPercent = threeSigRngDevPercent;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
        
        function set.threeSigAngDevPercent(obj, threeSigAngDevPercent)
            obj.threeSigAngDevPercent = threeSigAngDevPercent;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
        
        function executeVehicleComponent(obj, ~)
            obj.querySensor();
        end

        function querySensor(obj)
            detectableObjInds = false(size(obj.propObjs.propObjs));
            for(i=1:length(obj.propObjs.propObjs))
                detectableObjInds(i) = obj.isaDetectable(obj.propObjs.propObjs(i));
            end
            detectableObjs = obj.propObjs.propObjs(detectableObjInds);
            
            sensorOutput = NNS_SensorOutput(length(detectableObjs));
            for(i=length(detectableObjs):-1:1) %#ok<*NO4LP>
                propObj = detectableObjs(i);
                [tf, rng, bearing] = isPropObjectDetected(obj, propObj);
                
                if(tf == true)
                    outputRow = NNS_SensorOutputRow(obj, propObj, tf, rng, bearing);
                    sensorOutput.addQueryResult(i, outputRow);
                end
            end
            sensorOutput.trimEmpty();
            
            obj.lastSensorOutput = sensorOutput;
        end
        
        function [tf, rng, bearing] = isPropObjectDetected(obj, propObj)
            tf = true;
            rng = NaN;
            bearing = NaN;
            
            filterTf = obj.filter.doesObjectMeetFilter(propObj);
            if(filterTf == false)
                tf = false;
                return;
            end
                       
            p1 = obj.getAbsPosition();
            p2 = propObj.stateMgr.position;

            [heading,rng] = cart2pol(p2(1)-p1(1),p2(2)-p1(2));
            heading = angleZero2Pi(heading);
            bearing = angleZero2Pi(heading - obj.ship.stateMgr.heading);
            
            if(rng > obj.maxRng)
                tf = false;
                return;
            end
            
            pntAngle = obj.getAbsPntingAngle();
            [x1,y1] = pol2cart(pntAngle,1);
            [x2,y2] = pol2cart(heading,1);
            pntDiff = dang([x1 y1 0]', [x2 y2 0]');
            if(abs(pntDiff) > obj.curConeAngle/2)
                tf = false;
                return
            end
            
            %Need to apply the deviations here using "normrnd()"
            rng = normrnd(rng, obj.maxRng*obj.threeSigRngDevPercent/3);
            bearing = normrnd(bearing, obj.maxConeAngle*obj.threeSigAngDevPercent/3);
        end
        
        function sensorOutput = getSensorOutput(obj)
            sensorOutput = obj.lastSensorOutput;
        end
        
        function tf = sensorHasDetectedSomething(obj)
            tf = ~isempty(obj.lastSensorOutput) && length(obj.lastSensorOutput.outputs) > 0; %#ok<ISMT>
        end
            
        function drawObjectOnAxes(obj, hAxes)
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
        
        function power = getPowerDrawGen(obj)
            area = pi*obj.maxRng^2*(obj.maxConeAngle/(2*pi));
            
            power = -(area/1.5 + ...
                      10000*(obj.maxAllowableThreeSigRngDevPercent - obj.threeSigRngDevPercent) + ...
                      10000*(obj.maxAllowableThreeSigAngDevPercent - obj.threeSigAngDevPercent));
        end
        
        function radius = getCompRadiusForPower(obj)
            radius = 0.00025*abs(obj.getPowerDrawGen())+0.1;
        end
        
        function str = getInfoStrForComponent(obj)
            str = {};
            
            str{end+1} = sprintf('%s %10.3f m',         paddStr('Max. Sensor Range  =', 25), obj.maxRng);
            str{end+1} = sprintf('%s %10.3f deg',       paddStr('Max. Sensor Angle  =', 25), rad2deg(obj.maxConeAngle));
            str{end+1} = sprintf('%s %10.3f %%',        paddStr('Max. Range Error   =', 25), 100*obj.threeSigRngDevPercent);
            str{end+1} = sprintf('%s %10.3f %%',        paddStr('Max. Angular Error =', 25), 100*obj.threeSigAngDevPercent);
            str{end+1} = getShipCompEditorRightHRule();
            str{end+1} = sprintf('%s %10.3f W',         paddStr('Power Used         =', 25), abs(obj.getPowerDrawGen()));
            str{end+1} = sprintf('%s %10.3f m',         paddStr('Radius             =', 25), obj.getCompRadiusForPower());
            str{end+1} = sprintf('%s %10.3f kg',        paddStr('Mass               =', 25), obj.getMass());
            str{end+1} = sprintf('%s [%.2f, %.2f] m',   paddStr('Position (X,Y)     =', 25), obj.relPos(1), obj.relPos(2));
        end
        
        function hFig = createCompPropertiesEditorFigure(obj, handlesForShipCompEditUI)
            fH = @(src,evt) obj.compUpdated(src,evt, handlesForShipCompEditUI);
            sensorRngL = addlistener(obj,'maxRng','PostSet',fH);
            sensorCaL = addlistener(obj,'maxConeAngle','PostSet',fH);
            sensorRngDevL = addlistener(obj,'threeSigRngDevPercent','PostSet',fH);
            sensorAngDevL = addlistener(obj,'threeSigAngDevPercent','PostSet',fH);
            
            app = basicActiveSensorEditorGUI_App(obj);
            hFig = app.basicActiveSensorEditorGUI;
            hFig.CloseRequestFcn = @(src, evt) obj.activeSensorEditorCloseReqFunc(src, evt, sensorRngL, sensorCaL, sensorRngDevL, sensorAngDevL);
        end
        
        function charSize = getCharacteristicSizeForComp(obj)
            charSize = obj.getCompRadiusForPower();
        end
        
        function str = getShortCompName(obj)
            comps = obj.ship.components.getSensorComponents();
            ind = find(comps == obj,1,'first');
            str = sprintf('Sen[%i]',ind);
        end
    end
    
    methods(Static)
        function sensor = getDefaultBasicActiveSensor(ship)
            sensor = NNS_BasicActiveSensor(25,25,0.01,0.01,[0;0],ship);
        end
        
        function compUpdated(~,~,handles)
            updateDataDisplays(handles);
        end
        
        function activeSensorEditorCloseReqFunc(src, ~, sensorRngL, sensorCaL, sensorRngDevL, sensorAngDevL)
            delete(sensorRngL);
            delete(sensorCaL);
            delete(sensorRngDevL);
            delete(sensorAngDevL);
            delete(src);
        end
    end
end

