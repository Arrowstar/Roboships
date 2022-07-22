classdef(Abstract = true) NNS_AbstractGun < NNS_AbstractDrawableVehicleComponent
    %NNS_AbstractGun An abstract class for 'guns', classes that
    %create projectiles to shoot at other objects
       
    properties
%         drawer NNS_AbstractPropagatedObjectDrawer
%         ship NNS_PropagatedObject
    end
    
    methods
        fireGun(obj);
        tf = isGunLoaded(obj, curTime);
        drawObjectOnAxes(obj, hAxes);
    end
end