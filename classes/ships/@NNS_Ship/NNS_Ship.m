classdef NNS_Ship < NNS_PropagatedObject & NNS_ShootableObject & NNS_IsDetectable & NNS_SaveableObject & NNS_NeuralNetworkCapable & NNS_TracksScore
    %NNS_Ship Represents a ship on the battlefield.
    
    properties
        id double
        name char
        desc char
        team NNS_ShipTeam = NNS_ShipTeam.None
        
        hull NNS_AbstractHull
        components NNS_VehicleComponentList
        basicPropagator NNS_BasicPropagator
        arena NNS_Arena

        massCache(1,1) double = NaN;
        obsInfoCache = [];
    end
    
    methods
        function obj = NNS_Ship(name)
            %NNS_Ship Construct an instance of this class
            obj.name = name;
            obj.desc = '';
            
            obj.components = NNS_VehicleComponentList();
            obj.stateMgr = NNS_StateManager();
            obj.basicPropagator = NNS_BasicPropagator(obj.stateMgr, obj.components, obj);
            obj.basicPropagator.numSubsteps = 3;
            
            obj.id = rand();
                                   
            obj.drawer = NNS_ShipDrawer(obj);
        end
        
        function inializePropObj(obj)
            obj.active = true;

%             obj.stateMgr.setRandomizedPositionAndHeading([obj.arena.xLims, obj.arena.yLims],[0 360]);
                
            speed = norm(obj.stateMgr.velocity);
            obj.basicPropagator.speedCntrlr.setPIDParam(NNS_PidController.PID_SETPOINT, speed);
            
            heading = obj.stateMgr.heading;
            obj.basicPropagator.headingCntrlr.setPIDParam(NNS_PidController.PID_SETPOINT, heading);
            
            comps = obj.components.components;
            
            if(isempty(obj.components.getHullComponents()))
                obj.components.addComponent(obj.hull);
            end
            
            for(i=1:length(comps)) %#ok<*NO4LP>
                comps(i).initializeComponent();
            end

            obj.obsInfoCache = [];
        end
                
        function mass = getMass(obj)
            if(isnan(obj.massCache))
                mass = obj.hull.getMass();
                
                comps = obj.components.components;
                for(i=1:length(comps))
                    if(not(isa(comps(i),'NNS_AbstractHull')))
                        mass = mass + comps(i).getMass();
                    end
                end

                obj.massCache = mass;

            else
                mass = obj.massCache;
            end
        end

        function clearMassCache(obj)
            obj.massCache = NaN;
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
        
        function [netPower, powerUsed, powerGen] = getNetPower(obj)
            pwrdComps = obj.components.getPoweredComponents();
            
            netPower = 0;
            powerUsed = 0;
            powerGen = 0;
            for(i=1:length(pwrdComps))
                newPwr = pwrdComps(i).getPowerDrawGen();
                netPower = netPower + newPwr;
                
                if(newPwr > 0)
                    powerGen = powerGen + newPwr;
                else
                    powerUsed = powerUsed + abs(newPwr);
                end
            end
        end
        
        function propagateOneStep(obj, timeStep)  
            cntrlrs = obj.components.getControllerComps();
            for(i=1:length(cntrlrs))
                cntrlrs(i).executeNextOperation();
            end
            
            xLims = obj.arena.xLims;
            yLims = obj.arena.yLims;

            usesPid = obj.usesPidControllers();
            obj.basicPropagator.propagateOneStep(timeStep, xLims, yLims, usesPid);

            pos = obj.stateMgr.position;
            if(pos(1) <= min(xLims) || ...
               pos(1) >= max(xLims) || ...
               pos(2) <= min(yLims) || ...
               pos(2) >= max(yLims))

                againstArenaBndPenalty = -0.1;
                obj.addPointsToScore(againstArenaBndPenalty);
            end

            vel = obj.stateMgr.velocity;
            if(norm(vel) < 0.01)
                speedTooSlowPenalty = -0.1;
                obj.addPointsToScore(speedTooSlowPenalty);
            end

            hdgVect = obj.stateMgr.getHeadingUnitVector();
            if(abs(dang([vel;0], [hdgVect;0])) > deg2rad(135))
                facingAgainstVelPenalty = -0.1;
                obj.addPointsToScore(facingAgainstVelPenalty);
            end

            angRateRevsPerSec = abs(obj.stateMgr.angRate)/(2*pi);
            if(angRateRevsPerSec > 0.5)
                tooHighAngRatePenalty = -0.1;
                obj.addPointsToScore(tooHighAngRatePenalty);
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
            for(i=1:length(hComps))
                vertsH = hComps(i).getHullVertices();
                verts(:,1,i) = vertsH(:,1) + pos(1);   %#ok<AGROW>
                verts(:,2,i) = vertsH(:,2) + pos(2); %#ok<AGROW>
            end
        end
        
        function takeHit(obj, projectile)
            obj.hull.takeDamage(projectile.baseDamage);

            penalty = -0.1*projectile.baseDamage;
            obj.addPointsToScore(penalty);
            
            if(obj.getPlayerHealth() <= 0)
                obj.active = false;
                obj.destroyGraphics();
            end
        end
        
        function playerName = getPlayerName(obj)
            playerName = obj.name;
        end
        
        function health = getPlayerHealth(obj)
            health = obj.hull.getCurHitPoints();
        end

        function tf = usesPidControllers(obj)
            controllerComps = obj.components.getControllerComps();
            tf = any(usesPidController(controllerComps));
        end

        function addPointsToScore(obj, newPoints)
            obj.arena.scorekeeper.addPointsForPlayer(obj, newPoints);
        end
        
        function score = getCurrentScore(obj)
            score = obj.arena.scorekeeper.getScoreForPlayer(obj);
        end

        %% Neural Network functions
        function obsInfo = getObservationInfo(obj)
            if(isempty(obj.obsInfoCache))
                obsInfo = rlNumericSpec([1 8]);
                obsInfo.Name = '[time, x, y, vx, vy, heading, angVel, health]';
    
                %loop over components here
                nnComps = obj.components.getNeuralNetworkCapableComponents();
                for(i=1:length(nnComps))
                    nnComp = nnComps(i);
                    compObsInfo = nnComp.getObservationInfo();
    
                    if(not(isempty(compObsInfo)))
                        obsInfo(end+1) = compObsInfo; %#ok<AGROW> 
                    end
                end

                obj.obsInfoCache = obsInfo;

            else
                obsInfo = obj.obsInfoCache;
            end
        end

        function obs = getObservation(obj)
            time = obj.arena.simClock.curSimTime / obj.arena.simClock.endTime;
            position = obj.stateMgr.position / max(abs(obj.arena.xLims));
            velocity = obj.stateMgr.velocity / 10;
            heading = obj.stateMgr.heading / (2*pi);
            angVel = obj.stateMgr.angRate;
            health = obj.getPlayerHealth() / obj.hull.getMaxHitPoints();

            obs = {[time, position(:)', velocity(:)', heading, angVel, health]};

            %loop over components here
            nnComps = obj.components.getNeuralNetworkCapableComponents();
            for(i=1:length(nnComps))
                nnComp = nnComps(i);
                compObsInfo = nnComp.getObservationInfo();

                if(not(isempty(compObsInfo)))
                    obs(end+1) = nnComp.getObservation(); %#ok<AGROW> 
                end
            end
        end

        function actInfo = getActionInfo(obj)
            actInfo = rl.util.RLDataSpec.empty(1,0);

            %loop over components here
            nnComps = obj.components.getNeuralNetworkCapableComponents();
            for(i=1:length(nnComps))
                nnComp = nnComps(i);
                compActInfo = nnComp.getActionInfo();

                if(not(isempty(compActInfo)))
                    actInfo(end+1) = compActInfo; %#ok<AGROW> 
                end
            end
        end

        function execAction(obj, action, curTime)
            %noop
        end
    end
    
%% Static Methods
    methods(Static)
        function ship = createDefaultBasicShip(arena)
            ship = NNS_Ship('Untitled Ship');
            ship.arena = arena;
            
            ship.hull = NNS_BasicShipHull.createDefaultBasicShipHull(ship);
            ship.components.addComponent(NNS_BasicEngine.getDefaultBasicEngine(ship));
            ship.components.addComponent(NNS_BasicRudder.getDefaultBasicRudder(ship));
            
            pwrGen = NNS_BasicPowerGenerator.getDefaultBasicPowerGenerator(ship);
            pwrGen.relPos = [1;0];
            ship.components.addComponent(pwrGen);
            
            sensor = NNS_BasicActiveSensor.getDefaultBasicActiveSensor(ship);
            sensor.relPos = [-0.8;0];
            ship.components.addComponent(sensor);
            
            gun = NNS_BasicTurretedGun.getDefaultBasicTurretedGun(ship);
            gun.relPos = [-0.8;0];
            ship.components.addComponent(gun);
            
            %must be last
            controller = NNS_BasicShipController.getDefaultBasicController(ship);
            controller.relPos = [1.81;0];
            ship.components.addComponent(controller);
        end
    end
end

