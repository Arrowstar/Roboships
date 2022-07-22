classdef NNS_BasicActiveSensorSetFilterCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor NNS_BasicActiveSensor
        
        desiredFilterId NNS_ControllerNumeric 
        
        cmdTitle char = 'Set Filter'
        drawer NNS_AbstractControllerCommandDrawer
    end
    
    methods
        function obj = NNS_BasicActiveSensorSetFilterCntrlrOperation(sensor)
            obj.sensor = sensor;
            obj.drawer = NNS_BasicActiveSensorSetFilterCntrlrOperationDrawer(obj);
            obj.desiredFilterId = NNS_ControllerConstant(1);
        end
        
        function executeOperation(obj)
            obj.sensor.filter = NNS_AbstractSensorFilter.getFilterForId(obj.desiredFilterId.getValue(), obj.sensor);
        end
        
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function numerics = getNumeric(obj)
            numerics = obj.desiredFilterId;
        end
        
        function setNumeric(obj, numeric)
            obj.desiredFilterId = numeric;
        end
        
        function comp = getComponent(obj)
            comp = obj.sensor;
        end
        
        function set.desiredFilterId(obj,newFilterId)
            if(isa(newFilterId,'double'))
                newFilterId = NNS_ControllerConstant(newFilterId);
            end
            obj.desiredFilterId = newFilterId;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Set Filter';
        end
    end
end