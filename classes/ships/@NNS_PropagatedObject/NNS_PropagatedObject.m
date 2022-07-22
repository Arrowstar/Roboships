classdef (Abstract = true) NNS_PropagatedObject < matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    %NSS_Propagated An object which exists on the field and can be moved
    %linearly and rotationally via some propagation scheme.
    
    properties
        %state of object
        active logical = true
        stateMgr NNS_StateManager; 
        
        %drawing parameters of object
        drawer NNS_AbstractPropagatedObjectDrawer;
    end
    properties(Abstract = true)
        id double
    end
    
    methods
        function setInactiveAndRemove(obj)
            obj.active = false;           
        end
    end
    
    methods(Abstract = true)
        inializePropObj(obj);
        
        propagateOneStep(obj, timeStep);
        
        drawObjectToAxes(obj);
        
        destroyGraphics(obj);
        
        mass = getMass(obj);
        
        momInert = getMomentOfInertia(obj);
        
        frontArea = getFrontalSurfArea(obj);
        
        sideArea = getSideSurfArea(obj);
        
        CdL = getLinearDragCoeff(obj);
        
        CdR = getRotDragCoeff(obj);
        
        CdA = getLinearCdA(obj);
        
        CdA = getRotCdA(obj);
        
        netPrw = getNetPower(obj);
    end
    
    methods(Sealed)
        function tf = eq(A,B)
            tf = [A.id] == [B.id];
        end
        
        function tf = ne(A,B)
            tf = [A.id] ~= [B.id];
        end
    end
end

