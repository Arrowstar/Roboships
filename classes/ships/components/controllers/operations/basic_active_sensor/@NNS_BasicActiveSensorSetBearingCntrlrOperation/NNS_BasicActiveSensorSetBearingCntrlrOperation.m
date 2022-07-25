classdef NNS_BasicActiveSensorSetBearingCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sensor NNS_BasicActiveSensor
        
        desiredBearing NNS_ControllerNumeric %rad
        
        cmdTitle char = 'Set Bearing'
        drawer NNS_BasicActiveSensorSetBearingCntrlrOperationDrawer
    end
    
    methods
        function obj = NNS_BasicActiveSensorSetBearingCntrlrOperation(sensor)
            obj.sensor = sensor;
            obj.drawer = NNS_BasicActiveSensorSetBearingCntrlrOperationDrawer(obj);
            obj.desiredBearing = NNS_ControllerConstant(0);
        end
        
        function executeOperation(obj)
            obj.sensor.pointingBearing = angleZero2Pi(deg2rad(obj.desiredBearing.getValue()));
        end
        
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function numerics = getNumeric(obj)
            numerics = obj.desiredBearing;
        end
        
        function setNumeric(obj, numeric)
            obj.desiredBearing = numeric;
        end
        
        function comp = getComponent(obj)
            comp = obj.sensor;
        end
        
        function set.desiredBearing(obj,newBearing)
            if(isa(newBearing,'double'))
                newBearing = NNS_ControllerConstant(newBearing);
            end
            obj.desiredBearing = newBearing;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Set Bearing';
        end
    end
end