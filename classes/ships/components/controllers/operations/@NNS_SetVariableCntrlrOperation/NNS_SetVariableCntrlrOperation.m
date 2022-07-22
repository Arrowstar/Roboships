classdef NNS_SetVariableCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_SetVariableCntrlrOperation Summary of this class goes here
    %   Detailed explanation goes here
    
    properties       
        var NNS_ControllerVariable
        varSetToValue NNS_ControllerNumeric
        
        cmdTitle char = 'Set Variable';
        drawer NNS_SetVariableCntrlrOperationDrawer
    end
    
    methods
        function obj = NNS_SetVariableCntrlrOperation(~)
            obj.drawer = NNS_SetVariableCntrlrOperationDrawer(obj);
        end
        
        function executeOperation(obj)
            obj.var.setValue(obj.varSetToValue.getValue());
        end
                
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function numerics = getNumeric(obj)
            numerics(1) = obj.var;
            numerics(2) = obj.varSetToValue;
        end
        
        function setNumeric(obj, numeric)
            if(isa(numeric,'NNS_ControllerVariable'))
                obj.var = numeric;
            elseif(isa(numeric,'NNS_ControllerNumeric'))
                obj.varSetToValue = numeric;
            end
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Set Variable';
        end
    end
end