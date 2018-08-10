classdef NNS_BasicMissileSensorFilter < NNS_AbstractSensorFilter
    %NNS_AbstractSensorFilter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_BasicMissileSensorFilter(sensor)
            obj.sensor = sensor;
        end
        
        function tf = doesObjectMeetFilter(obj, propObj)
            tf = false;
            if(isa(propObj,'NNS_BasicMissile') && ...
                   propObj.ownerShip ~= obj.sensor.ship)
                tf = true;
            end
        end
    end
end