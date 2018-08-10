classdef NNS_SensorOutput < matlab.mixin.SetGet
    %NNS_SensorOutput Represents output from a sensor query
    
    properties
        outputs@NNS_SensorOutputRow
    end
    
    methods
        function obj = NNS_SensorOutput(lgth)
            %NNS_SensorOutput Construct an instance of this class
            obj.outputs = NNS_SensorOutputRow.empty(lgth,0);
        end
        
        function addQueryResult(obj, i, outputRow)
            obj.outputs(i) = outputRow;
        end
        
        function rng = getRangeToClosestDetection(obj)
            [val, ~] = min(arrayfun(@getRange, obj.getDetectedOutputRows()));
            
            if(~isempty(val))
                rng = val;
            else
                rng = NaN;
            end
        end
        
        function detOutputs = getDetectedOutputRows(obj)
            detInds = arrayfun(@wasDetected, obj.outputs);
            detOutputs = obj.outputs(detInds);
        end
        
        function trimEmpty(obj)
            if(numel(obj.outputs) == 0)
                obj.outputs = NNS_SensorOutputRow.empty(0,0);
                return;
            end
            
            tf = arrayfun(@isempty,obj.outputs);
            obj.outputs = obj.outputs(not(tf));
        end
    end
end

