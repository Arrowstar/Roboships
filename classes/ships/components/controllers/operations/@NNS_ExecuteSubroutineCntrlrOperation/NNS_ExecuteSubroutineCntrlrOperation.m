classdef NNS_ExecuteSubroutineCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
   
    properties
        subroutine@NNS_ControllerSubroutine;
        
        cmdTitle@char = 'Subroutine';
        drawer@NNS_AbstractControllerCommandDrawer
    end
    
    methods
        function obj = NNS_ExecuteSubroutineCntrlrOperation(~)
            obj.drawer = NNS_ExecuteSubroutineCntrlrOperationDrawer(obj);
        end
        
        function executeOperation(obj)
            obj.subroutine.executeNextOp();
        end
        
        function nextOp = getNextOperationForInd(obj, ~)
            if(isempty(obj.subroutine.opNext))
                nextOp = obj.nextOp{1};
            else
                nextOp = obj;
            end
        end
        
        function nextOp = getNextOperationForIndForProgrammingUI(obj, ~)
            nextOp = obj.nextOp{1};
        end
        
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function setNumeric(obj, ~)
            %nothing
        end

    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Execute Subroutine';
        end
    end
end