classdef NNS_ConstantControllerParameter < NNS_ControllerComponentParameter
    %NNS_ConstantControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship NNS_Ship
        paramName char = 'Constant';
        
        constant NNS_ControllerConstant
    end
    
    methods
        function obj = NNS_ConstantControllerParameter(ship)
            obj.ship = ship;
            obj.constant = NNS_ControllerConstant(0);
        end
        
        function value = getValue(obj)
            value = obj.constant.getValue();
        end
        
        function str = getValueAsStr(obj)
            str = obj.constant.getValueAsStr();
        end
        
        function comp = getComponent(obj)
            comp = obj.ship;
        end
        
        function setConstValue(obj, newValue)
            obj.constant.value = newValue;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Constant';
        end
    end
end