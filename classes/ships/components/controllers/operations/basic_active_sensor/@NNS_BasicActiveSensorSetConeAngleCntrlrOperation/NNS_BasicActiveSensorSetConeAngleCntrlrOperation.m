classdef NNS_BasicActiveSensorSetConeAngleCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor NNS_BasicActiveSensor
        
        desiredConeAngle NNS_ControllerNumeric %rad
        
        cmdTitle char = 'Set Cone Angle';
        drawer NNS_BasicActiveSensorSetConeAngleCntrlrOperationDrawer
    end
    
    methods
        function obj = NNS_BasicActiveSensorSetConeAngleCntrlrOperation(sensor)
            obj.sensor = sensor;
            obj.drawer = NNS_BasicActiveSensorSetConeAngleCntrlrOperationDrawer(obj);
            obj.desiredConeAngle = NNS_ControllerConstant(0);
        end
        
        function executeOperation(obj)
            obj.sensor.curConeAngle = deg2rad(obj.desiredConeAngle.getValue());
        end
        
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function numerics = getNumeric(obj)
            numerics = obj.desiredConeAngle;
        end
        
        function setNumeric(obj, numeric)
            obj.desiredConeAngle = numeric;
        end
        
        function comp = getComponent(obj)
            comp = obj.sensor;
        end        
        
        function set.desiredConeAngle(obj,newConeAngle)
            if(isa(newConeAngle,'double'))
                newConeAngle = NNS_ControllerConstant(newConeAngle);
            end
            obj.desiredConeAngle = newConeAngle;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Set Cone Angle';
        end
    end
end