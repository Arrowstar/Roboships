classdef NNS_ObjectToControllerObjectMapEntryTypeEnum < matlab.mixin.SetGet
    %NNS_ObjectToControllerObjectMapEntryTypeEnum Summary of this class goes here
    %   Detailed explanation goes here
        
    enumeration
        Operation(1);
        Condition(2);
        Parameter(3);
    end
    
    properties
        id@double
    end
    
    methods
        function obj = NNS_ObjectToControllerObjectMapEntryTypeEnum(id)
            obj.id = id;
        end
    end
end

