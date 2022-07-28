classdef(Abstract) NNS_AbstractSensorFilter < matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    %NNS_AbstractSensorFilter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor NNS_AbstractSensor
    end

    properties(Constant, Abstract)
        typeEnum NNS_SensorFilterEnum
    end
    
    methods
        tf = doesObjectMeetFilter(obj, propObj)
        
    end
    
    methods(Static)
        function filter = getFilterForId(id, sensor)
            switch id
                case 0
                    filter = NNS_NoneFilteredSensorFilter(sensor);
                case 1
                    filter = NNS_EnemyShipsSensorFilter(sensor);
                case 2
                    filter = NNS_AlliedShipsSensorFilter(sensor);
                case 3
                    filter = NNS_AnyShipsSensorFilter(sensor);
                case 4
                    filter = NNS_AnyProjectileSensorFilter(sensor);
                case 5
                    filter = NNS_BasicProjectileSensorFilter(sensor);
                case 6
                    filter = NNS_BasicMineSensorFilter(sensor);
                case 7
                    filter = NNS_BasicMissileSensorFilter(sensor);
                case -99
                    filter = NNS_EnemyShipsForBasicMissileSensorFilter(sensor);
                otherwise
                    filter = NNS_EnemyShipsSensorFilter(sensor);
                    warning('Could not find a filter for id "%i", so returned enemy ship filter.', id);
            end
        end
    end
end