classdef NNS_AlliedShipsSensorFilter < NNS_AbstractSensorFilter
    %NNS_AbstractSensorFilter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        typeEnum = NNS_SensorFilterEnum.AlliedShips
    end
    
    methods
        function obj = NNS_AlliedShipsSensorFilter(sensor)
            obj.sensor = sensor;
        end
        
        function tf = doesObjectMeetFilter(obj, propObj)
            tf = false;
            if(isa(propObj,'NNS_Ship') && ...
               propObj ~= obj.sensor.ship && ...
               obj.sensor.ship.team ~= NNS_ShipTeam.None && ...
               propObj.team == obj.sensor.ship.team)
                tf = true;
            end
        end
    end
end