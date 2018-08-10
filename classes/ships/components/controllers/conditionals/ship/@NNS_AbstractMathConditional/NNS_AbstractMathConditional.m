classdef(Abstract) NNS_AbstractMathConditional < NNS_AbstractControllerConditional
    
    properties
        ship@NNS_Ship
        
        drawer@NNS_AbstractControllerCommandDrawer
        
        lhs@NNS_ControllerNumeric
        rhs@NNS_ControllerNumeric
        sideLastSet@char = 'none';
        
        condAns@logical = false
    end
    
    methods       
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
        
        function numerics = getNumeric(obj)
            numerics(1) = obj.lhs;
            numerics(2) = obj.rhs;
        end
        
        function setNumeric(obj, numeric)
            if(strcmpi(obj.sideLastSet,'none') || strcmpi(obj.sideLastSet,'right'))
                obj.lhs = numeric;
                obj.sideLastSet = 'left';
            else
                obj.rhs = numeric;
                obj.sideLastSet = 'right';
            end
        end
        
        function comp = getComponent(obj)
            comp = obj.ship;
        end
    end
end

