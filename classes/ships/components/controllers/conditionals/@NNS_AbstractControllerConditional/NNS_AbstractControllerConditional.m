classdef(Abstract) NNS_AbstractControllerConditional < NNS_AbstractControllerOperation
    %NNS_ControllerConditional Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function nextOp = getNextOperation(~)
            error('Conditionals must use getNextOperationForInd()!');
        end
        
        function setNextOperation(~, ~)
            error('Conditionals must use setNextOperationForInd()!');
        end
        
        function nextOp = getNextOperationForInd(obj, ind)
            if(ind < 1)
                ind = 1;
            elseif(ind > obj.numOutputs)
                ind = obj.numOutputs;
            end
            
            nextOp = obj.nextOp{ind};
        end
        
        function setNextOperationForInd(obj,nextOp,ind)
            if(ind < 1)
                ind = 1;
            elseif(ind > obj.numOutputs)
                ind = obj.numOutputs;
            end
            
            obj.nextOp{ind} = nextOp;
        end
        
        function nextOp = getNextOperationForIndForProgrammingUI(obj, ind)
            nextOp = obj.getNextOperationForInd(ind);
        end
    end
end

