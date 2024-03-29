classdef NNS_EnemyShipsSensorFilter < NNS_AbstractSensorFilter
    %NNS_AbstractSensorFilter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        typeEnum = NNS_SensorFilterEnum.EnemyShips
    end
    
    methods
        function obj = NNS_EnemyShipsSensorFilter(sensor)
            obj.sensor = sensor;
        end
        
        function tf = doesObjectMeetFilter(obj, propObj)
            tf = false;
            if(propObj ~= obj.sensor.ship && ...
               isa(propObj,'NNS_Ship') && ...
               (not(propObj.team == obj.sensor.ship.team) || ...
               obj.sensor.ship.team == NNS_ShipTeam.None))
                tf = true;
            end
        end
    end
end