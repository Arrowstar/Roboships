classdef NNS_ShipXPositionControllerParameter < NNS_ControllerComponentParameter
    %NNS_ShipXPositionControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship@NNS_Ship
        paramName@char = 'Ship X Location';
    end
    
    methods
        function obj = NNS_ShipXPositionControllerParameter(ship)
            obj.ship = ship;
        end
        
        function value = getValue(obj)
            value = obj.ship.stateMgr.position(1);
        end
        
        function str = getValueAsStr(~)
            str = '[Ship_X_Position]';
        end

        function comp = getComponent(obj)
            comp = obj.ship;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Ship X Location';
        end
    end
end