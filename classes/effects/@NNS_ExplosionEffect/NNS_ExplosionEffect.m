classdef NNS_ExplosionEffect < NNS_AbstractEffect
    %NNS_BasicProjectile Summary of this class goes here
    
    properties
        createTime@double %s
        duration@double = 2; %s
        initialRadius = 1; %m
        finalRadius = 2; %m
        curRadius@double = 0.25;
        
        initColor = [1 0 0];
        finalColor = [255, 207, 158]/255;
    end
    
    methods
        function obj = NNS_ExplosionEffect(ownerShip, relPosToShip, createTime)
            obj.stateMgr = NNS_StateManager();
            
            obj.relPosToShip = relPosToShip;
            obj.ownerShip = ownerShip;
            obj.createTime = createTime;
            
            obj.curRadius = obj.initialRadius;
            
            obj.id = rand();
            
            obj.drawer = NNS_ExplosionEffectDrawer(obj);
        end
        
        function inializePropObj(obj)
            obj.curRadius = obj.initialRadius;
        end
        
        function propagateOneStep(obj, timeStep)
            shipPos = obj.ownerShip.stateMgr.position;
            obj.stateMgr.position = shipPos + obj.relPosToShip;
            
            obj.curRadius = obj.curRadius + timeStep*((obj.finalRadius - obj.initialRadius)/obj.duration);
            
            if(obj.curRadius > obj.finalRadius)
                obj.active = false;
                obj.drawer.destroyGraphics();
            end
        end
    end
end