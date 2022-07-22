classdef NNS_IsGreaterThanOrEqualToConditional < NNS_AbstractMathConditional
    %NNS_IsEqualToConditional Summary of this class goes here
    %   Detailed explanation goes here
       
    properties        
        cmdTitle char = 'Is Greater Than Or Equal To?';
    end
    
    methods
        function obj = NNS_IsGreaterThanOrEqualToConditional(ship)
            obj.ship = ship;
            obj.drawer = NNS_IsGreaterThanOrEqualToConditionalDrawer(obj);
            obj.numOutputs = 2;
            
            for(i=1:obj.numOutputs) %#ok<*NO4LP>
                obj.nextOp{i} = NNS_AbstractControllerOperation.empty(0,0);
            end
        end
        
        function executeOperation(obj)
            obj.condAns = (obj.lhs.getValue() >= obj.rhs.getValue());
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Is Greater Than Or Equal To (>=)';
        end
    end
end