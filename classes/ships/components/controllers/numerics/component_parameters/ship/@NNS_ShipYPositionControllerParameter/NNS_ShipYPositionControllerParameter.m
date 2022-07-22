classdef NNS_ShipYPositionControllerParameter < NNS_ControllerComponentParameter
    %NNS_ShipYPositionControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship NNS_Ship
        paramName char = 'Ship Y Location';
    end
    
    methods
        function obj = NNS_ShipYPositionControllerParameter(ship)
            obj.ship = ship;
        end
        
        function value = getValue(obj)
            value = obj.ship.stateMgr.position(2);
        end
        
        function str = getValueAsStr(~)
            str = '[Ship_Y_Position]';
        end
        
        function comp = getComponent(obj)
            comp = obj.ship;
        end        
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Ship Y Location';
        end
    end
end