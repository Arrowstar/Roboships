classdef(Abstract = true) NNS_AbstractHull < NNS_AbstractDrawableVehicleComponent
    %NNS_AbstractHull An abstract class for 'hulls', classes that
    %represent the physics geometry of a propagation object.
    
    properties(Abstract = true)
        drawer@NNS_AbstractPropagatedObjectDrawer
    end
    
    methods
        hullVerts = getHullVertices(obj);
        
        maxHitPoints = getMaxHitPoints(obj);
        
        curHitPoints = getCurHitPoints(obj);
        
        takeDamage(obj, damagePts);
        
        mass = getMass(obj);
        
        momInert = getMomentOfInertia(obj);
        
        frontArea = getFrontalSurfArea(obj);
        
        sideArea = getSideSurfArea(obj);
        
        CdL = getLinearDragCoeff(obj);
        
        CdR = getRotDragCoeff(obj);
        
        CdA = getLinearCdA(obj);
        
        CdA = getRotCdA(obj);
    end
    
    methods(Abstract = true)
        drawObjectOnAxes(obj, hAxes);
    end
end