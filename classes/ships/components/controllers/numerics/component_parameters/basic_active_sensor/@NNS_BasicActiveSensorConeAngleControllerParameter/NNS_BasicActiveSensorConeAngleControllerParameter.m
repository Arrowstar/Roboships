classdef NNS_BasicActiveSensorConeAngleControllerParameter < NNS_ControllerComponentParameter
    %NNS_BasicActiveSensorConeAngleControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor@NNS_BasicActiveSensor
        paramName@char = 'Active Radar Angle';
    end
    
    methods
        function obj = NNS_BasicActiveSensorConeAngleControllerParameter(sensor)
            obj.sensor = sensor;
        end
        
        function value = getValue(obj)
            value = rad2deg(obj.sensor.curConeAngle);
        end
        
        function str = getValueAsStr(obj)
            str = sprintf('%s: %s', obj.sensor.getShortCompName(), '[Act_Radar_Angle]'); 
        end
        
        function comp = getComponent(obj)
            comp = obj.sensor;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Radar Angle';
        end
    end
end