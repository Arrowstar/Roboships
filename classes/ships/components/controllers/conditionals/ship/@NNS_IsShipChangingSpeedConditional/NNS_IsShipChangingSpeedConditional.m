classdef NNS_IsShipChangingSpeedConditional < NNS_AbstractControllerConditional
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
       
    properties        
        ship@NNS_Ship
        
        cmdTitle@char = 'Is Ship Changing Speed?';
        drawer@NNS_AbstractControllerCommandDrawer
        
        condAns@logical = false
    end
    
    methods
        function obj = NNS_IsShipChangingSpeedConditional(ship)
            obj.ship = ship;
            obj.drawer = NNS_IsShipChangingSpeedConditionalDrawer(obj);
            obj.numOutputs = 2;
            
            for(i=1:obj.numOutputs) %#ok<*NO4LP>
                obj.nextOp{i} = NNS_AbstractControllerOperation.empty(0,0);
            end
        end
        
        function executeOperation(obj)
            pid = obj.ship.basicPropagator.speedCntrlr;
            setPoint = pid.getPIDParam(pid.PID_SETPOINT);
            curVal = norm(obj.ship.stateMgr.velocity);
            
            percDiffSpeed = abs(setPoint - curVal)/setPoint;
            
            if(percDiffSpeed > 0.05)
                obj.condAns = true;
            else
                obj.condAns = false;
            end
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
            comp = obj.ship;
        end        
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Is Ship Changing Speed';
        end
    end
end