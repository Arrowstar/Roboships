classdef NNS_ShipHealthControllerParameter < NNS_ControllerComponentParameter
    %NNS_ShipSpeedControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship@NNS_Ship
        paramName@char = 'Ship Health';
    end
    
    methods
        function obj = NNS_ShipHealthControllerParameter(ship)
            obj.ship = ship;
        end
        
        function value = getValue(obj)
            value = norm(obj.ship.getPlayerHealth());
        end
        
        function str = getValueAsStr(~)
            str = '[Ship_Health]';
        end

        function comp = getComponent(obj)
            comp = obj.ship;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Ship Health';
        end
    end
end