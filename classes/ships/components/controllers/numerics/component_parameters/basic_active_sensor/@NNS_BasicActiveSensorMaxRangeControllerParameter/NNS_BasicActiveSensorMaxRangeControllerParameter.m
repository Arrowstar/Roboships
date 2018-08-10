classdef NNS_BasicActiveSensorMaxRangeControllerParameter < NNS_ControllerComponentParameter
    %NNS_BasicActiveSensorMaxRangeControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor@NNS_BasicActiveSensor
        paramName@char = 'Active Radar Range';
    end
    
    methods
        function obj = NNS_BasicActiveSensorMaxRangeControllerParameter(sensor)
            obj.sensor = sensor;
        end
        
        function value = getValue(obj)
            value = obj.sensor.maxRng;
        end
        
        function str = getValueAsStr(obj)
            str = sprintf('%s: %s', obj.sensor.getShortCompName(), '[Act_Radar_Range]'); 
        end
        
        function comp = getComponent(obj)
            comp = obj.sensor;
        end        
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Radar Range';
        end
    end
end