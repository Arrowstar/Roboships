classdef NNS_SetShipHeadingCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        desiredHeading NNS_ControllerNumeric %rad
        
        ship NNS_PropagatedObject
        
        cmdTitle char = 'Set Ship Heading'
        drawer NNS_SetShipHeadingCntrlrOperationDrawer
    end
    
    methods
        function obj = NNS_SetShipHeadingCntrlrOperation(ship)
            obj.ship = ship;
            obj.drawer = NNS_SetShipHeadingCntrlrOperationDrawer(obj);
            obj.desiredHeading = NNS_ControllerConstant(0);
        end
        
        function executeOperation(obj)
            pid = obj.ship.basicPropagator.headingCntrlr;
            pid.setPIDParam(pid.PID_SETPOINT, angleZero2Pi(deg2rad(obj.desiredHeading.getValue())));
%             fprintf('Set Heading: %0.3f deg\n', rad2deg(angleZero2Pi(deg2rad(obj.desiredHeading.getValue()))));
        end
               
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function numerics = getNumeric(obj)
            numerics = obj.desiredHeading;
        end
        
        function setNumeric(obj, numeric)
            obj.desiredHeading = numeric;
        end
        
        function comp = getComponent(obj)
            comp = obj.ship;
        end
        
        function set.desiredHeading(obj,newHeading)
            if(isa(newHeading,'double'))
                newHeading = NNS_ControllerConstant(newHeading);
            end
            obj.desiredHeading = newHeading;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Set Ship Heading';
        end
    end
end