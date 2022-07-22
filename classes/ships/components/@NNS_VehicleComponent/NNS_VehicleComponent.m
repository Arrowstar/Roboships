classdef (Abstract = true) NNS_VehicleComponent < matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    %NSS_VehicleComponent A class which represents a "thing" which can be
    %on a vehicle: an engine, gun turret, rudder, sensor, etc.
    
    properties(Abstract)
        id double
    end
    
    properties(Abstract,Constant)
        typeName char
    end
    
    methods(Abstract = true)
        initializeComponent(obj);
        
        copiedComp = copy(obj);
        
        mass = getMass(obj);
        
        str = getShortCompName(obj);
    end
    
    methods(Sealed)
        function out = eq(A,B)
            if(isempty(A) || isempty(B))
                out = false;
            else
                out = [A.id] == [B.id];
            end
        end
    end
end

