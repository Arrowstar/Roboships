classdef NNS_ControllerVariable < NNS_ControllerNumeric
    %NNS_ControllerVariable Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name@char
        value@NNS_ControllerConstant
    end
    
    methods
        function obj = NNS_ControllerVariable(name)
            obj.name = name;
            obj.value = NNS_ControllerConstant(0);
        end
        
        function value = getValue(obj)
            value = obj.value.getValue();
        end
        
        function str = getValueAsStr(obj)
            str = sprintf('<var: %s>', obj.name);
        end

        function setValue(obj, newValue)
            obj.value = NNS_ControllerConstant(newValue);
        end
    end
end

