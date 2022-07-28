classdef NNS_EnemyShipsForBasicMissileSensorFilter < NNS_AbstractSensorFilter
    %NNS_AbstractSensorFilter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        typeEnum = NNS_SensorFilterEnum.EnemyShipsBasicMissile
    end
    
    methods
        function obj = NNS_EnemyShipsForBasicMissileSensorFilter(sensor)
            obj.sensor = sensor;
        end
        
        function tf = doesObjectMeetFilter(obj, propObj)
            tf = false;
            if(isa(propObj,'NNS_Ship') && ...
               propObj ~= obj.sensor.ship && ...
               not(propObj.team == obj.sensor.ship.team) && ...
               isa(obj.sensor.ship,'NNS_BasicMissile') && ...
               not(propObj == obj.sensor.ship.ownerShip))
                tf = true;
            end
        end
    end
end