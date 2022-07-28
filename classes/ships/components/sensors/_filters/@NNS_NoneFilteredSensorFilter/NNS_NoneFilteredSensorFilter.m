classdef NNS_NoneFilteredSensorFilter < NNS_AbstractSensorFilter
    %NNS_NoneFilteredSensorFilter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        typeEnum = NNS_SensorFilterEnum.NoFilter
    end
    
    methods
        function obj = NNS_NoneFilteredSensorFilter(sensor)
            obj.sensor = sensor;
        end
        
        function tf = doesObjectMeetFilter(obj, propObj)
            if(isa(propObj,'NNS_AbstractProjectile'))
                if(propObj.ownerShip == obj.sensor.ship)
                    tf = false;
                else
                    tf = true;
                end
            else
                tf = true;
            end
        end
    end
end