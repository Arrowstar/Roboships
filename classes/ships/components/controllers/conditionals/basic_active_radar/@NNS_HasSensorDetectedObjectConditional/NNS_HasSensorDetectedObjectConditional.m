classdef NNS_HasSensorDetectedObjectConditional < NNS_AbstractControllerConditional
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
       
    properties        
        sensor@NNS_BasicActiveSensor
        
        cmdTitle@char = 'Has Detected?';
        drawer@NNS_AbstractControllerCommandDrawer
        
        condAns@logical = false
    end
    
    methods
        function obj = NNS_HasSensorDetectedObjectConditional(sensor)
            obj.sensor = sensor;
            obj.drawer = NNS_HasSensorDetectedObjectConditionalDrawer(obj);
            obj.numOutputs = 2;
            
            for(i=1:obj.numOutputs) %#ok<*NO4LP>
                obj.nextOp{i} = NNS_AbstractControllerOperation.empty(0,0);
            end
        end
        
        function executeOperation(obj)
            obj.condAns = obj.sensor.sensorHasDetectedSomething();
        end
        
        function nextOp = getNextOperation(obj)
            if(obj.condAns == true)
                nextOp = obj.getNextOperationForInd(1);
            else
                nextOp = obj.getNextOperationForInd(2);
            end
        end
               
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function setNumeric(obj, numeric)
            %nothing
        end
        
        function comp = getComponent(obj)
            comp = obj.sensor;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Has Detected';
        end
    end
end