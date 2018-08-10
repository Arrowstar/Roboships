classdef NNS_BasicMine < NNS_AbstractProjectile & NNS_IsDetectable
    %NNS_BasicProjectile Summary of this class goes here
    
    properties
        maxRange@double = 1E99;  %m
        initPos@double = [0;0]; %m
        createTime@double = -Inf;
        baseDamage@double;
        armTime@double;
        maxTime@double = 30;
        
        propObjs@NNS_PropagatedObjectList
        clock@NNS_SimClock;
        
        minRng@double = Inf;
        
        id@double = rand();
    end
    
    methods
        function obj = NNS_BasicMine(initPos, ownerShip, propObjs, clock, baseDamage, armTime)
            %NNS_BasicProjectile Construct an instance of this class
            obj.stateMgr = NNS_StateManager();
            
            obj.ownerShip = ownerShip;
            obj.propObjs = propObjs;
            obj.clock = clock;
            obj.baseDamage = baseDamage;
            obj.createTime = obj.clock.curSimTime;
            obj.armTime = armTime;
            
            obj.effectiveRng = 2;
            
            obj.id = rand();
            
            obj.initPos = initPos;
            
            obj.drawer = NNS_BasicMineDrawer(obj);
        end
        
        function inializePropObj(obj)
            
        end
        
        function propagateOneStep(obj, timeStep)            
            %check for collisions
            if(obj.isMineArmed())
                obj.checkForHitAndDoDamage();
            end
            
            if(obj.hasMineExpired())
                obj.setInactiveAndRemove();
            end
        end
        
        function tf = isMineArmed(obj)
            tf = obj.clock.curSimTime >= obj.createTime + obj.armTime;
        end
        
        function tf = hasMineExpired(obj)
            tf = obj.clock.curSimTime >= obj.createTime + obj.maxTime;
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