classdef(Abstract) NNS_AbstractControllerOperation  < NNS_CmdListboxEntry & matlab.mixin.Heterogeneous
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        canvassPos(1,2) double = [0,0];
        
        numOutputs@double = 1;
        outputCircCanvassPos@cell = cell(5,1);
        
        isDeletable@logical = true;
    end
    
    properties(Access=protected)
        nextOp@cell = {NNS_AbstractControllerOperation.empty(0,0)};
    end
    
    properties(Abstract = true)
        cmdTitle@char
        drawer@NNS_AbstractControllerCommandDrawer
    end
    
    methods        
        executeOperation(obj);
        
        function nextOp = getNextOperation(obj)
            nextOp = obj.getNextOperationForInd(1);
        end
        
        function setNextOperation(obj,nextOp)
           obj.setNextOperationForInd(nextOp,1);
        end
               
        function nextOp = getNextOperationForInd(obj, ~)
            nextOp = obj.nextOp{1};
        end
        
        function setNextOperationForInd(obj,nextOp,~)
            obj.nextOp{1} = nextOp;
        end
        
        function nextOp = getNextOperationForIndForProgrammingUI(obj, ~)
            nextOp = obj.getNextOperationForInd(1);
        end
        
        tf = requiresTimeStep(obj);
        
        function numerics = getNumeric(obj)
            numerics = NNS_ControllerNumeric.empty(0,0);
        end
        
        setNumeric(obj, numeric);
        
        function comp = getComponent(obj)
            comp = NNS_VehicleComponent.empty(0,0);
        end
    end
end