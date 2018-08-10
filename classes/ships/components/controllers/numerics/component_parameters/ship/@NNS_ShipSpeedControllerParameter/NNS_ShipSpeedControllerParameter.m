classdef NNS_ShipSpeedControllerParameter < NNS_ControllerComponentParameter
    %NNS_ShipSpeedControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship@NNS_Ship
        paramName@char = 'Ship Speed';
    end
    
    methods
        function obj = NNS_ShipSpeedControllerParameter(ship)
            obj.ship = ship;
        end
        
        function value = getValue(obj)
            value = norm(obj.ship.stateMgr.velocity);
        end
        
        function str = getValueAsStr(~)
            str = '[Ship_Speed]';
        end
        
        function comp = getComponent(obj)
            comp = obj.ship;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Ship Speed';
        end
    end
end