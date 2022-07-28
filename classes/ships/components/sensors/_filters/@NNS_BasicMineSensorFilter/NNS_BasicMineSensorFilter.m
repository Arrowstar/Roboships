classdef NNS_BasicMineSensorFilter < NNS_AbstractSensorFilter
    %NNS_AbstractSensorFilter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        typeEnum = NNS_SensorFilterEnum.BasicMine
    end
    
    methods
        function obj = NNS_BasicMineSensorFilter(sensor)
            obj.sensor = sensor;
        end
        
        function tf = doesObjectMeetFilter(obj, propObj)
            tf = false;
            if(isa(propObj,'NNS_BasicMine') && ...
                   propObj.ownerShip ~= obj.sensor.ship)
                tf = true;
            end
        end
    end
end