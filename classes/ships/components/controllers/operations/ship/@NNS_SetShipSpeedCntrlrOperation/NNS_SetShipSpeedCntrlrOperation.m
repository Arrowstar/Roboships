classdef NNS_SetShipSpeedCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
   
    properties
        desiredSpeed@NNS_ControllerNumeric; %m/s
        
        ship@NNS_Ship
        
        cmdTitle@char = 'Set Speed';
        drawer@NNS_AbstractControllerCommandDrawer
    end
    
    methods
        function obj = NNS_SetShipSpeedCntrlrOperation(ship)
            obj.ship = ship;
            obj.drawer = NNS_SetShipSpeedCntrlrOperationDrawer(obj);
            obj.desiredSpeed = NNS_ControllerConstant(0);
        end
        
        function executeOperation(obj)
            pid = obj.ship.basicPropagator.speedCntrlr;
            pid.setPIDParam(pid.PID_SETPOINT, obj.desiredSpeed.getValue());
        end
        
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function numerics = getNumeric(obj)
            numerics = obj.desiredSpeed;
        end
        
        function setNumeric(obj, numeric)
            obj.desiredSpeed = numeric;
        end
        
        function comp = getComponent(obj)
            comp = obj.ship;
        end
        
        function set.desiredSpeed(obj,newSpeed)
            if(isa(newSpeed,'double'))
                newSpeed = NNS_ControllerConstant(newSpeed);
            end
            obj.desiredSpeed = newSpeed;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Set Ship Speed';
        end
    end
end