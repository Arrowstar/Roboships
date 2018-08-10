classdef NNS_BasicActiveSensorBearingControllerParameter < NNS_ControllerComponentParameter
    %NNS_BasicActiveSensorBearingControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor@NNS_BasicActiveSensor
        paramName@char = 'Active Radar Bearing';
    end
    
    methods
        function obj = NNS_BasicActiveSensorBearingControllerParameter(sensor)
            obj.sensor = sensor;
        end
        
        function value = getValue(obj)
            value = rad2deg(obj.sensor.pointingBearing);
        end
        
        function str = getValueAsStr(obj)
            str = sprintf('%s: %s', obj.sensor.getShortCompName(), '[Act_Radar_Bearing]'); 
        end
        
        function comp = getComponent(obj)
            comp = obj.sensor;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Radar Bearing';
        end
    end
end