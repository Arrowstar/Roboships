classdef NNS_BasicActiveSensorDetObjBearingControllerParam < NNS_ControllerComponentParameter
    %NNS_BasicActiveSensorBearingControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor@NNS_BasicActiveSensor
        paramName@char = 'Detected Obj. Bearing';
    end
    
    methods
        function obj = NNS_BasicActiveSensorDetObjBearingControllerParam(sensor)
            obj.sensor = sensor;
        end
        
        function value = getValue(obj)
            sensorOutput = obj.sensor.getSensorOutput();
            if(~isempty(sensorOutput) && length(sensorOutput.outputs)>0) %#ok<ISMT>
                output = sensorOutput.outputs(1);
                value = rad2deg(output.bearing);
            else
                value = 0;
            end
        end
        
        function str = getValueAsStr(obj)
            str = sprintf('%s: %s', obj.sensor.getShortCompName(), '[Act_Radar_Det_Bearing]'); 
        end
        
        function comp = getComponent(obj)
            comp = obj.sensor;
        end        
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Detected Bearing';
        end
    end
end