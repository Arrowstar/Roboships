classdef NNS_BasicProjectile < NNS_AbstractProjectile
    %NNS_BasicProjectile Summary of this class goes here
    
    properties
        maxRange double = 1E99;  %m
        initPos double = [0;0]; %m
        baseDamage double;
        
        components NNS_VehicleComponentList
        basicPropagator NNS_BasicPropagator
        
        propObjs NNS_PropagatedObjectList
        clock NNS_SimClock;
        xLims double
        yLims double
        
        minRng double = Inf;
        
        id double = rand();
    end
    
    methods
        function obj = NNS_BasicProjectile(initPos, ownerShip, propObjs, clock, xLims, yLims, baseDamage)
            %NNS_BasicProjectile Construct an instance of this class
            obj.components = NNS_VehicleComponentList();
            obj.stateMgr = NNS_StateManager();
            obj.basicPropagator = NNS_BasicPropagator(obj.stateMgr, obj.components, obj);
            obj.basicPropagator.numSubsteps = 1;
            
            obj.ownerShip = ownerShip;
            obj.propObjs = propObjs;
            obj.clock = clock;
            obj.xLims = xLims;
            obj.yLims = yLims;
            obj.baseDamage = baseDamage;
            
            obj.basicPropagator.iterator = @(odefun,tspan,y0) ode1(odefun,tspan,y0);
            
            obj.id = rand();
            
            obj.initPos = initPos;
            
            obj.drawer = NNS_BasicPropjectileDrawer(obj);
        end
        
        function inializePropObj(obj)
            
        end
        
        function propagateOneStep(obj, timeStep)
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
%                 obj.awardMinRngPoints();
                obj.setInactiveAndRemove();
            end
            
            %If at or beyond an arena bound, disable this
            if(pos(1) <= obj.xLims(1) || pos(1) >= obj.xLims(2) ||... 
               pos(2) <= obj.yLims(1) || pos(2) >= obj.yLims(2))
%                 obj.awardMinRngPoints();
                obj.setInactiveAndRemove();
            end
        end
        
        function rngPts = getPtsAwardedByRng(obj)
            maxPtsRng = 100; %m
            rngPts = (-obj.baseDamage/maxPtsRng)*obj.minRng + obj.baseDamage;
        end
        
        function awardMinRngPoints(obj)
            if(obj.active == true)
                rngPts = obj.getPtsAwardedByRng();
                if(rngPts > 0)
                    obj.ownerShip.addPointsToScore(rngPts);
                end
            end 
        end
               
        function drawObjectToAxes(obj, hAxes)
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
        
        function damage = getBaseDamage(obj)
            damage = obj.baseDamage;
        end
        
        function p = getNetPower(obj)
            p = 0;
        end
        
        function cda = getRotCdA(obj)
            cda = 0;
        end
        
        function cda = getLinearCdA(obj)
            cda = 0;
        end
        
        function cda = getRotDragCoeff(obj)
            cda = 0;
        end
          	
        function cda = getLinearDragCoeff(obj)
            cda = 0;
        end
    	
        function cda = getSideSurfArea(obj)
            cda = 0;
        end
       	
        function cda = getFrontalSurfArea(obj)
            cda = 0;
        end
    	
        function cda = getMomentOfInertia(obj)
            cda = 1;
        end
        
        function cda = getMass(obj)
            cda = 1;
        end     	
    end
end