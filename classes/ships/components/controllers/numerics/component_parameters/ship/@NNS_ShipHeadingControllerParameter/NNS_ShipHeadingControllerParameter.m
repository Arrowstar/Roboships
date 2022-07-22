classdef NNS_ShipHeadingControllerParameter < NNS_ControllerComponentParameter
    %NNS_ShipXPositionControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship NNS_PropagatedObject
        paramName char = 'Ship Heading';
    end
    
    methods
        function obj = NNS_ShipHeadingControllerParameter(ship)
            obj.ship = ship;
        end
        
        function value = getValue(obj)
            value = rad2deg(obj.ship.stateMgr.heading);
        end
        
        function str = getValueAsStr(~)
            str = '[Ship_Heading]';
        end
        
        function comp = getComponent(obj)
            comp = obj.ship;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Ship Heading';
        end
    end
end