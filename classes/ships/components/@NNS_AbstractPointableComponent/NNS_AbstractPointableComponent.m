classdef(Abstract = true) NNS_AbstractPointableComponent < matlab.mixin.SetGet
    %NNS_AbstractPointableComponent Provides basic functions and properties
    %for vehicle components that can rotate, point, and are located on a
    %particular point on the ship.  Not meant to be used stand-alone but as
    %a subset along with an astract class that implements VehicleComponent.
    
    properties(Abstract = true)
        ship 
    end
    
    properties
        pointingBearing = deg2rad(0);   % rad
    end
    
    methods        
        function pntingAng = getAbsPntingAngle(obj)
            pntingAng = angleZero2Pi(obj.ship.stateMgr.heading + obj.pointingBearing);
        end
        
        function pntingUnitVector = getPointingUnitVector(obj)
            [x,y] = pol2cart(obj.getAbsPntingAngle(),1);
            pntingUnitVector = [x;y];
        end
    end
end

