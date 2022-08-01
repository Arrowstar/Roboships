classdef NNS_BasicMineLayer < NNS_AbstractGun & NNS_AbstractPoweredComponent & NNS_NeuralNetworkCapable
    %NNS_BasicTurretedGun A basic gun that can rotate itself and shoot
    %projectiles
    
    properties
        lastShotTime double = -Inf; %s

        drawer NNS_AbstractPropagatedObjectDrawer
        ship NNS_PropagatedObject

        id double
        relPos double         % m - relative to the origin of vessel it's mounted on

        obsInfoCache = [];
        actionInfoCache = [];
    end

    properties(Dependent)
        propObjs NNS_PropagatedObjectList
    end
    
    properties(SetObservable)
        reloadTime double   %can fire once every "reloadTime" seconds
        baseDamage double
        armTime double %second, duration to wait before checking
    end
    
    properties(Constant)
        typeName char = 'Mine Layer'
        minBaseDamage = 100;
        maxBaseDamage = 1000; 
        minReloadTime = 1;    %sec
        maxReloadTime = 10;
    end
    
    methods
        function obj = NNS_BasicMineLayer(reloadTime, baseDamage, armTime, relPos, ship)
            %NNS_BasicTurretedGun Construct an instance of this class
            obj.reloadTime = reloadTime;
            obj.baseDamage = baseDamage;
            obj.armTime = armTime;
            obj.ship = ship;
            obj.relPos = relPos;
            
            obj.id = rand();
            obj.drawer = NNS_BasicMineLayerDrawer(ship, obj);
        end
        
        function initializeComponent(obj)  
            obj.lastShotTime = -Inf;

            obj.obsInfoCache = [];
            obj.actionInfoCache = [];
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
                pos = obj.getAbsPosition();
                mine = NNS_BasicMine(pos, obj.ship, obj.propObjs, obj.ship.arena.simClock, obj.baseDamage, obj.armTime);
                mine.stateMgr.position = pos;
                mine.stateMgr.velocity = [0;0];

                obj.propObjs.addPropagatedObject(mine);

                obj.lastShotTime = curTime;

                if(isa(obj.ship, 'NNS_TracksScore'))
                    penalty = -0.01*obj.baseDamage;
                    obj.ship.addPointsToScore(penalty);
                end
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
            
            app = basicMineLayerEditorGUI_App(obj);
            hFig = app.basicMineLayerEditorGUI;
            hFig.CloseRequestFcn = @(src, evt) obj.mineLayerEditorCloseReqFunc(src, evt, gunReloadTimeL, gunBaseDamageL);
        end
        
        function power = getPowerDrawGen(obj)
            power = -( (((750-100)/(obj.maxBaseDamage - obj.minBaseDamage))*(obj.baseDamage - obj.minBaseDamage) + 100) + ...
                       (((100-750)/(obj.maxReloadTime - obj.minReloadTime))*(obj.reloadTime - obj.minReloadTime) + 750) );
        end
        
        function radius = getCompRadiusForPower(obj)
            radius = 0.00020*abs(obj.getPowerDrawGen())+0.25;
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
            if(isempty(obj.obsInfoCache))
                obsInfo = rlNumericSpec([1, 1]);
                obsInfo.Name = sprintf('%s: [Is Loaded]', obj.getShortCompName());

                obj.obsInfoCache = obsInfo;
            else
                obsInfo = obj.obsInfoCache;
            end
        end

        function obs = getObservation(obj)
            isLoaded = 1;
            
            obs = {isLoaded};
        end

        function actInfo = getActionInfo(obj)
            if(isempty(obj.actionInfoCache))
                actInfo = rlFiniteSetSpec([0 1]);
                actInfo.Name = sprintf('%s: [Lay Mine]', obj.getShortCompName());   

                obj.actionInfoCache = actInfo;

            else
                actInfo = obj.actionInfoCache;
            end
        end

        function execAction(obj, action, curTime)
            if(action == 1)
                obj.fireGun(curTime);
            end
        end
    end
    
    methods(Static)
        function gun = getDefaultBasicMineLayer(ship)
            gun = NNS_BasicMineLayer(NNS_BasicMineLayer.minReloadTime, NNS_BasicMineLayer.minBaseDamage, 5, [0;0], ship);
        end
        
        function compUpdated(~,~,handles)
            updateDataDisplays(handles);
        end
        
        function mineLayerEditorCloseReqFunc(src, ~, gunReloadTimeL, gunBaseDamageL)
            delete(gunReloadTimeL);
            delete(gunBaseDamageL);
            delete(src);
        end
    end
end