classdef NNS_BasicMissileLauncher < NNS_AbstractGun & NNS_AbstractPointableComponent & NNS_AbstractPoweredComponent & NNS_NeuralNetworkCapable
    %NNS_BasicTurretedGun A basic gun that can rotate itself and shoot
    %projectiles
    
    properties
        lastShotTime double = -Inf; %s

        drawer NNS_AbstractPropagatedObjectDrawer
        ship NNS_PropagatedObject

        id double
        relPos double         % m - relative to the origin of vessel it's mounted on
    end

    properties(Dependent)
        propObjs NNS_PropagatedObjectList
        xLims double
        yLims double
    end
    
    properties(SetObservable)
        reloadTime double   %can fire once every "reloadTime" seconds
        baseDamage double
    end
    
    properties(Constant)
        typeName char = 'Missile Launcher'
        minBaseDamage = 10;
        maxBaseDamage = 500; 
        minReloadTime = 5;    %sec
        maxReloadTime = 60;
    end
    
    methods
        function obj = NNS_BasicMissileLauncher(reloadTime, baseDamage, relPos, ship)
            obj.reloadTime = reloadTime;
            obj.baseDamage = baseDamage;
            obj.ship = ship;
            obj.relPos = relPos;
            
            obj.id = rand();
            obj.drawer = NNS_BasicMissileLauncherDrawer(ship, obj);
        end
        
        function initializeComponent(obj)  
            obj.lastShotTime = -Inf;
            obj.pointingBearing = 0;
        end
        
        function copiedComp = copy(obj)
            copiedComp = obj.getDefaultBasicTurretedGun(obj.ship);
            copiedComp.lastShotTime = obj.lastShotTime;
            copiedComp.reloadTime = obj.reloadTime;
            copiedComp.baseDamage = obj.baseDamage;
        end   
        
        function mass = getMass(obj)
            mass = 300*(pi*obj.getCompRadiusForPower()^2);
        end
        
        function propObjs = get.propObjs(obj)
            propObjs = obj.ship.arena.propObjs;
        end
        
        function xLims = get.xLims(obj)
            xLims = obj.ship.arena.xLims;
        end
        
        function yLims = get.yLims(obj)
            yLims = obj.ship.arena.yLims;
        end
        
        function set.reloadTime(obj, reloadTime)
            obj.reloadTime = reloadTime;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
        
        function set.baseDamage(obj, baseDamage)
            obj.baseDamage = baseDamage;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
                
        function fireGun(obj, curTime)  
            if(obj.isGunLoaded(curTime))
                pntVect = obj.getPointingUnitVector();
                shipRelVelVector = 10*pntVect;
                absVelVector = shipRelVelVector;

                pos = obj.getAbsPosition();
                missile = NNS_BasicMissile.createDefaultBasicMissile(pos, obj.ship, obj.baseDamage);
                missile.stateMgr.position = pos;
                missile.stateMgr.velocity = absVelVector;
                
                heading = cart2pol(pntVect(1), pntVect(2));
                missile.stateMgr.heading = heading;
                missile.basicPropagator.headingCntrlr.setPIDParam(NNS_PidController.PID_SETPOINT, heading);
                
                obj.propObjs.addPropagatedObject(missile);

                obj.lastShotTime = curTime;

%                 if(isa(obj.ship, 'NNS_TracksScore'))
%                     penalty = -0.02*obj.baseDamage;
%                     obj.ship.addPointsToScore(penalty);
%                 end
            end
        end
        
        function tf = isGunLoaded(obj, curTime)
            tf = obj.lastShotTime + obj.reloadTime <= curTime;
        end
                        
        function drawObjectOnAxes(obj, hAxes)
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
        
        function str = getInfoStrForComponent(obj)
            str = {};
            
            str{end+1} = sprintf('%s %10.3f sec',     paddStr('Reload Time        =', 25), obj.reloadTime);
            str{end+1} = sprintf('%s %10.3f ',        paddStr('Base Damage        =', 25), obj.baseDamage);
            str{end+1} = getShipCompEditorRightHRule();
            str{end+1} = sprintf('%s %10.3f W',       paddStr('Power Used         =', 25), abs(obj.getPowerDrawGen()));
            str{end+1} = sprintf('%s %10.3f m',       paddStr('Radius             =', 25), obj.getCompRadiusForPower());
            str{end+1} = sprintf('%s %10.3f kg',      paddStr('Mass               =', 25), obj.getMass());
            str{end+1} = sprintf('%s [%.2f, %.2f] m', paddStr('Position (X,Y)     =', 25), obj.relPos(1), obj.relPos(2));
        end
        
        function hFig = createCompPropertiesEditorFigure(obj, handlesForShipCompEditUI)
            fH = @(src,evt) obj.compUpdated(src,evt, handlesForShipCompEditUI);
            gunReloadTimeL = addlistener(obj,'reloadTime','PostSet',fH);
            gunBaseDamageL = addlistener(obj,'baseDamage','PostSet',fH);
            
            app = basicMissileLauncherEditorGUI_App(obj);
            hFig = app.basicMissileLauncherEditorGUI;
            hFig.CloseRequestFcn = @(src, evt) obj.missileLauncherEditorCloseReqFunc(src, evt, gunReloadTimeL, gunBaseDamageL);
        end
        
        function power = getPowerDrawGen(obj)
            power = -( (((750-100)/(obj.maxBaseDamage - obj.minBaseDamage))*(obj.baseDamage - obj.minBaseDamage) + 100) + ...
                       (((100-750)/(obj.maxReloadTime - obj.minReloadTime))*(obj.reloadTime - obj.minReloadTime) + 750) );
        end
        
        function radius = getCompRadiusForPower(obj)
            radius = 0.00040*abs(obj.getPowerDrawGen())+0.25;
        end
        
        function charSize = getCharacteristicSizeForComp(obj)
            charSize = obj.getCompRadiusForPower();
        end
        
        function str = getShortCompName(obj)
            comps = obj.ship.components.getGunComponents();
            ind = find(comps == obj,1,'first');
            str = sprintf('Wpn[%i]',ind);
        end

        function obsInfo = getObservationInfo(obj)
            obsInfo = rlNumericSpec([1, 2]);
            obsInfo.Name = sprintf('%s: [Pointing Angle, Is Loaded]', obj.getShortCompName());
        end

        function obs = getObservation(obj)
            pntAngle = obj.getAbsPntingAngle() / (2*pi);
            isLoaded = 1;
            
            obs = {[pntAngle, isLoaded]};
        end

        function actInfo = getActionInfo(obj)
            a = deg2rad([-10 -1 0 1 10]);
            b = [0 1];
            actions = num2cell(combvec(a,b)',2);

            actInfo = rlFiniteSetSpec(actions);
            actInfo.Name = sprintf('%s: [Delta Launcher Heading, Launch Missile]', obj.getShortCompName());  
        end

        function execAction(obj, action, curTime)
            obj.pointingBearing = angleZero2Pi(obj.pointingBearing + action(1));

            if(action(2) == 1)
                obj.fireGun(curTime);
            end
        end
    end
    
    methods(Static)
        function gun = getDefaultBasicMissileLauncher(ship)
            gun = NNS_BasicMissileLauncher(15, 100, [0;0], ship);
        end
        
        function compUpdated(~,~,handles)
            updateDataDisplays(handles);
        end
        
        function missileLauncherEditorCloseReqFunc(src, ~, gunReloadTimeL, gunBaseDamageL)
            delete(gunReloadTimeL);
            delete(gunBaseDamageL);
            delete(src);
        end
    end
end