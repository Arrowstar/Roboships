classdef NNS_BasicMissile < NNS_ShootableObject & NNS_AbstractProjectile & NNS_IsDetectable
    %NNS_BasicProjectile Summary of this class goes here
    
    properties
        maxRange double = 1E99;  %m
        initPos double = [0;0]; %m
        baseDamage double;
        
        hull NNS_AbstractHull
        components NNS_VehicleComponentList
        basicPropagator NNS_BasicPropagator
       
        team NNS_ShipTeam = NNS_ShipTeam.None
        minRng double = Inf;
        
        id double = rand();
    end
    
    properties(Dependent)
        clock 
        xLims
        yLims 
        propObjs
        arena
    end
    
    methods
        function obj = NNS_BasicMissile(initPos, ownerShip, baseDamage)
            %NNS_BasicProjectile Construct an instance of this class
            obj.components = NNS_VehicleComponentList();
            obj.stateMgr = NNS_StateManager();
            obj.basicPropagator = NNS_BasicPropagator(obj.stateMgr, obj.components, obj);
            obj.basicPropagator.numSubsteps = 3;
            
            obj.ownerShip = ownerShip;
            obj.baseDamage = baseDamage;
            
            obj.id = rand();
            
            obj.initPos = initPos;
            
            obj.drawer = NNS_BasicMissileDrawer(obj);
        end
        
        function inializePropObj(obj)
            
        end
        
        function val = get.clock(obj)
            val = obj.ownerShip.arena.simClock;
        end
        
        function val = get.xLims(obj)
            val = obj.ownerShip.arena.xLims;
        end
        
        function val = get.yLims(obj)
            val = obj.ownerShip.arena.yLims;
        end
        
        function val = get.propObjs(obj)
            val = obj.ownerShip.arena.propObjs;
        end
        
        function val = get.arena(obj)
            val = obj.ownerShip.arena;
        end
        
        function propagateOneStep(obj, timeStep)
            cntrlr = obj.components.getControllerComps();
            cntrlr(1).executeNextOperation();
            
            obj.basicPropagator.propagateOneStep(timeStep, obj.xLims, obj.yLims);
            pos = obj.stateMgr.position;
            
            %check for collisions
            obj.checkForHitAndDoDamage();
            
            %If dist traveled is greater than or equal to the max range,
            %disable this.
            p1 = obj.initPos;
            p2 = pos;
            distTraveled = hypot(p2(1)-p1(1), p2(2)-p1(2));
            if(distTraveled>=obj.maxRange)
                obj.setInactiveAndRemove();
            end
            
            %If at or beyond an arena bound, disable this
            if(pos(1) <= obj.xLims(1) || pos(1) >= obj.xLims(2) ||... 
               pos(2) <= obj.yLims(1) || pos(2) >= obj.yLims(2))
                obj.setInactiveAndRemove();
            end
        end
               
        function drawObjectToAxes(obj, hAxes)
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
        
        function verts = getVertsForHitCheck(obj)
            hComps = obj.components.getHullComponents();
                       
            pos = obj.stateMgr.position;
            for(i=1:length(hComps)) %#ok<*NO4LP>
                vertsH = hComps(i).getHullVertices();
                verts(:,1,i) = vertsH(:,1) + pos(1);   %#ok<AGROW>
                verts(:,2,i) = vertsH(:,2) + pos(2); %#ok<AGROW>
            end
        end
        
        function takeHit(obj, projectile)
            obj.hull.takeDamage(projectile.baseDamage);
            
            if(obj.getPlayerHealth() <= 0)
                obj.active = false;
                obj.destroyGraphics();
            end
        end
        
        function health = getPlayerHealth(obj)
            health = obj.hull.getCurHitPoints();
        end
        
        function damage = getBaseDamage(obj)
            damage = obj.baseDamage;
        end
        
        function p = getNetPower(obj)
            p = 0;
        end
        
        function mass = getMass(obj)
            mass = obj.hull.getMass();
        end
        
        function momInert = getMomentOfInertia(obj)
            momInert = obj.hull.getMomentOfInertia();
        end
        
        function frontArea = getFrontalSurfArea(obj)
            frontArea = obj.hull.getFrontalSurfArea();
        end
        
        function sideArea = getSideSurfArea(obj)
            sideArea = obj.hull.getSideSurfArea();
        end
        
        function CdL = getLinearDragCoeff(obj)
            CdL = obj.hull.getLinearDragCoeff();
        end
        
        function CdR = getRotDragCoeff(obj)
            CdR = obj.hull.getRotDragCoeff();
        end
        
        function CdA = getLinearCdA(obj)
            CdA = obj.hull.getLinearCdA();
        end
        
        function CdA = getRotCdA(obj)
            CdA = obj.hull.getRotCdA();
        end  	
    end
    
    methods(Static)
        function missile = createDefaultBasicMissile(initPos, ownerShip, baseDamage)
            missile = NNS_BasicMissile(initPos, ownerShip, baseDamage);
            
            missile.team = ownerShip.team;
            
            missile.basicPropagator.speedCntrlr.setPIDParam(NNS_PidController.PID_SETPOINT, 1E99);
            missile.basicPropagator.headingCntrlr.Kp = 30;
            missile.basicPropagator.headingCntrlr.Ki = 89;
            missile.basicPropagator.headingCntrlr.Kd = 100;
            
            hull = NNS_BasicShipHull.createDefaultBasicShipHull(missile);
            hull.hullVerts = [1/2 -1/4;
                              1/2  1/4;
                             -1/2, 1/4;
                             -1/2, -1/4];
            hull.hullThickness = 1;
            missile.hull = hull;
            missile.components.addComponent(hull);
            
            engine = NNS_BasicEngine.getDefaultBasicEngine(missile);
            engine.maxThrust = 1000;
            missile.components.addComponent(engine);
            
            rudder = NNS_BasicRudder.getDefaultBasicRudder(missile);
            rudder.maxTorque = 600;
            missile.components.addComponent(rudder);
            
            sensor = NNS_BasicActiveSensor.getDefaultBasicActiveSensor(missile);
            sensor.maxRng = 75; 
            sensor.maxConeAngle = pi;
            sensor.curConeAngle = pi;
            sensor.threeSigRngDevPercent = 0;
            sensor.threeSigAngDevPercent = 0;
            missile.components.addComponent(sensor);
            
            controller = NNS_BasicShipController.getDefaultBasicController(missile);
            missile.components.addComponent(controller);
            sr = controller.getMainSubroutine();
            
            startOp = sr.operations(1);
            
            filterOp = NNS_BasicActiveSensorSetFilterCntrlrOperation(sensor);
            filterId = NNS_ConstantControllerParameter(ownerShip);
            filterId.constant = NNS_ControllerConstant(-99);
            filterOp.desiredFilterId = filterId;
            sr.addOperation(filterOp);
            startOp.setNextOperation(filterOp);
            
            querySensorOp = NNS_BasicActiveSensorQueryCntrlrOperation(sensor);
            sr.addOperation(querySensorOp);
            filterOp.setNextOperation(querySensorOp);
            
            hasDetectedOp = NNS_HasSensorDetectedObjectConditional(sensor);
            sr.addOperation(hasDetectedOp);
            querySensorOp.setNextOperation(hasDetectedOp);
            
            sensorDetectBearingParam = NNS_BasicActiveSensorDetObjBearingControllerParam(sensor);
            headingParam = NNS_ShipHeadingControllerParameter(missile);
            mathParam = NNS_MathControllerParameter(missile);
            addMathExpr = NNS_ControllerAdditionMathExpression();
            mathParam.math = addMathExpr;
            addMathExpr.setInput(NNS_ControllerParameterMathExpression(sensorDetectBearingParam),1);
            addMathExpr.setInput(NNS_ControllerParameterMathExpression(headingParam),2);
            
            setHeadingOp = NNS_SetShipHeadingCntrlrOperation(missile);
            setHeadingOp.setNumeric(mathParam);
            hasDetectedOp.setNextOperationForInd(setHeadingOp,1);
            
            setHeadingOp.setNextOperation(querySensorOp);
            hasDetectedOp.setNextOperationForInd(querySensorOp,2);
        end
    end
end