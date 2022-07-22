classdef NNS_BasicActiveSensorQueryCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor NNS_BasicActiveSensor
        
        cmdTitle char = 'Query Sensor'
        drawer NNS_AbstractControllerCommandDrawer
    end
    
    methods
        function obj = NNS_BasicActiveSensorQueryCntrlrOperation(sensor)
            obj.sensor = sensor;
            obj.drawer = NNS_BasicActiveSensorQueryCntrlrOperationDrawer(obj);
        end
        
        function executeOperation(obj)
            obj.sensor.querySensor();
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
            str = 'Query Sensor';
        end
    end
end