classdef NNS_SensorOutputRow < matlab.mixin.SetGet
    %NNS_SensorOutputRow Represents the results a single sensor query on
    %one detectable object
    
    properties
        sensor NNS_AbstractSensor
        propObj NNS_PropagatedObject
        detected logical = false;
        range double
        bearing double
    end
    
    methods
        function obj = NNS_SensorOutputRow(sensor, propObj, detected, range, bearing)
            %NNS_SensorOutputRow Construct an instance of this class
            if(nargin > 0)
                obj.sensor = sensor;
                obj.propObj = propObj;
                obj.detected = detected;
                obj.range = range;
                obj.bearing = bearing;
            end
        end
        
        function tf = wasDetected(obj)
            tf = obj.detected;
        end
        
        function rng = getRange(obj)
            rng = obj.range;
        end
        
        function rng = getBearing(obj)
            rng = obj.bearing;
        end
        
        function tf = isempty(obj)
            tf = isempty(obj.propObj);
        end
    end
end

