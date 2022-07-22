classdef NNS_BasicTurretedGun < NNS_AbstractGun & NNS_AbstractPointableComponent & NNS_AbstractPoweredComponent
    %NNS_BasicTurretedGun A basic gun that can rotate itself and shoot
    %projectiles
    
    properties
        lastShotTime double = -Inf; %s

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
        roundSpeed double   %m/s - speed of shell
        baseDamage double
        angleError double   %rad
    end
    
    properties(Constant)
        typeName char = 'Turreted Cannon'
        minMuzzleVelocity = 5;  %m/s
        maxMuzzleVelocity = 50; %m/s
        minBaseDamage = 5;
        maxBaseDamage = 200; 
        maxMaxAngularError = 25; %deg
        minReloadTime = 0.1;    %sec
        maxReloadTime = 25;
    end
    
    methods
        function obj = NNS_BasicTurretedGun(reloadTime, roundSpeed, baseDamage, angleError, relPos, ship)
            %NNS_BasicTurretedGun Construct an instance of this class
            obj.reloadTime = reloadTime;
            obj.roundSpeed = roundSpeed;
            obj.baseDamage = baseDamage;
            obj.angleError = angleError;
            obj.ship = ship;
            obj.relPos = relPos;
            
            obj.id = rand();
            obj.drawer = NNS_BasicTurretedGunDrawer(ship, obj);
        end
        
        function initializeComponent(obj)  
            obj.lastShotTime = -Inf;
        end
        
        function copiedComp = copy(obj)
            copiedComp = obj.getDefaultBasicTurretedGun(obj.ship);
            copiedComp.lastShotTime = obj.lastShotTime;
            copiedComp.reloadTime = obj.reloadTime;
            copiedComp.roundSpeed = obj.roundSpeed;
            copiedComp.baseDamage = obj.baseDamage;
            copiedComp.angleError = obj.angleError;
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
        
        function set.roundSpeed(obj, roundSpeed)
            obj.roundSpeed = roundSpeed;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
        
        function set.baseDamage(obj, baseDamage)
            obj.baseDamage = baseDamage;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
        
        function set.angleError(obj, angleError)
            obj.angleError = angleError;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
                
        function fireGun(obj, curTime)  
            if(obj.isGunLoaded(curTime))
                theta = normrnd(0, obj.angleError/3);
                R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
                pntVect = obj.getPointingUnitVector();
                pntVect = R * pntVect;
                shipRelVelVector = obj.roundSpeed*pntVect;
                absVelVector = shipRelVelVector();

                pos = obj.getAbsPosition();
                projectile = NNS_BasicProjectile(pos, obj.ship, obj.propObjs, obj.ship.arena.simClock, obj.xLims, obj.yLims, obj.baseDamage);
                projectile.stateMgr.position = pos;
                projectile.stateMgr.velocity = absVelVector;


                obj.propObjs.addPropagatedObject(projectile);

                obj.lastShotTime = curTime;
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
            
            str{end+1} = sprintf('%s %10.3f m/s',     paddStr('Muzzle Velocity    =', 25), obj.roundSpeed);
            str{end+1} = sprintf('%s %10.3f sec',     paddStr('Reload Time        =', 25), obj.reloadTime);
            str{end+1} = sprintf('%s %10.3f ',        paddStr('Base Damage        =', 25), obj.baseDamage);
            str{end+1} = sprintf('%s %10.3f deg',     paddStr('Max. Angular Error =', 25), rad2deg(obj.angleError));
            str{end+1} = getShipCompEditorRightHRule();
            str{end+1} = sprintf('%s %10.3f W',       paddStr('Power Used         =', 25), abs(obj.getPowerDrawGen()));
            str{end+1} = sprintf('%s %10.3f m',       paddStr('Radius             =', 25), obj.getCompRadiusForPower());
            str{end+1} = sprintf('%s %10.3f kg',      paddStr('Mass               =', 25), obj.getMass());
            str{end+1} = sprintf('%s [%.2f, %.2f] m', paddStr('Position (X,Y)     =', 25), obj.relPos(1), obj.relPos(2));
        end
        
        function hFig = createCompPropertiesEditorFigure(obj, handlesForShipCompEditUI)
            fH = @(src,evt) obj.compUpdated(src,evt, handlesForShipCompEditUI);
            gunReloadTimeL = addlistener(obj,'reloadTime','PostSet',fH);
            gunRoundSpeedL = addlistener(obj,'roundSpeed','PostSet',fH);
            gunBaseDamageL = addlistener(obj,'baseDamage','PostSet',fH);
            gunAngleErrorL = addlistener(obj,'angleError','PostSet',fH);
            
            hFig = basicTurretedGunEditorGUI(obj);
            hFig.CloseRequestFcn = @(src, evt) obj.turretedGunEditorCloseReqFunc(src, evt, gunReloadTimeL, gunRoundSpeedL, gunBaseDamageL, gunAngleErrorL);
        end
        
        function power = getPowerDrawGen(obj)
            shellMass = (obj.baseDamage/55+1)^3;
                      
            power = -((1/2)*shellMass*obj.roundSpeed^2 + ...      %round speed
                      (1/obj.reloadTime)*shellMass^2 + ...        %reload time
                      ((1/(obj.angleError+1)))*100*shellMass)/40; %AngleError
        end
        
        function radius = getCompRadiusForPower(obj)
            radius = 0.0003*abs(obj.getPowerDrawGen())+0.25;
        end
        
        function charSize = getCharacteristicSizeForComp(obj)
            charSize = obj.getCompRadiusForPower();
        end
        
        function str = getShortCompName(obj)
            comps = obj.ship.components.getGunComponents();
            ind = find(comps == obj,1,'first');
            str = sprintf('Wpn[%i]',ind);
        end
    end
    
    methods(Static)
        function gun = getDefaultBasicTurretedGun(ship)
            gun = NNS_BasicTurretedGun(1, 10, 100, deg2rad(2.5), [0;0], ship);
        end
        
        function compUpdated(~,~,handles)
            updateDataDisplays(handles);
        end
        
        function turretedGunEditorCloseReqFunc(src, ~, gunReloadTimeL, gunRoundSpeedL, gunBaseDamageL, gunAngleErrorL)
            delete(gunReloadTimeL);
            delete(gunRoundSpeedL);
            delete(gunAngleErrorL);
            delete(gunBaseDamageL);
            delete(src);
        end
    end
end