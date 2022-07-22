classdef NNS_BasicActiveSensorDetObjRangeControllerParam < NNS_ControllerComponentParameter
    %NNS_BasicActiveSensorBearingControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor NNS_BasicActiveSensor
        paramName char = 'Detected Obj. Range';
    end
    
    methods
        function obj = NNS_BasicActiveSensorDetObjRangeControllerParam(sensor)
            obj.sensor = sensor;
        end
        
        function value = getValue(obj)
            sensorOutput = obj.sensor.getSensorOutput();
            if(~isempty(sensorOutput) && length(sensorOutput.outputs)>0) %#ok<ISMT>
                output = sensorOutput.outputs(1);
                value = output.range;
            else
                value = 0;
            end
        end
        
        function str = getValueAsStr(obj)
            str = sprintf('%s: %s', obj.sensor.getShortCompName(), '[Act_Radar_Det_Range]'); 
        end

        function comp = getComponent(obj)
            comp = obj.sensor;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Detected Range';
        end
    end
end