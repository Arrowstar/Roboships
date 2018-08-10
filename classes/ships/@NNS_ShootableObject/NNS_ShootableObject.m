classdef(Abstract) NNS_ShootableObject < matlab.mixin.SetGet
    %NNS_AbstractShootablePropagatedObject Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods(Abstract)
        verts = getVertsForHitCheck(obj);
        
        takeHit(obj, projectile);
    end
end

