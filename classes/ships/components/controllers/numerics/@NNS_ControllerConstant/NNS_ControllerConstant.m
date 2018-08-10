classdef NNS_ControllerConstant < NNS_ControllerNumeric 
    %NNS_ControllerConstant Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        value@double
    end
    
    methods
        function obj = NNS_ControllerConstant(value)
            obj.value = value;
        end
        
        function value = getValue(obj)
            value = obj.value;
        end
        
        function str = getValueAsStr(obj)
            str = sprintf('%.3f',obj.getValue());
        end
    end
end

