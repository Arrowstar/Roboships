classdef NNS_ControllerVariableList < matlab.mixin.SetGet
    %NNS_ControllerVariableList Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        variables(1,:) NNS_ControllerVariable
    end
    
    methods
        function obj = NNS_ControllerVariableList()
            obj.variables = NNS_ControllerVariable.empty(1,0);
        end
        
        function addNewVariable(obj, newVar)
            obj.variables(end+1) = newVar;
        end
        
        function removeVariable(obj, varToRemove)
            obj.variables(obj.variables == varToRemove) = [];
        end
        
        function tf = doesVarNameExist(obj, varName)
            tf = ismember(varName, {obj.variables.name});
        end
        
        function var = getVariableAtIndex(obj, ind)
            if(ind > length(obj.variables))
                var = NNS_ControllerVariable.empty(1,0);
            else
                var = obj.variables(ind);
            end
        end
        
        function str = getListboxStr(obj)
            if(isempty(obj.variables))
                str = '<html><i>None';
            else
                str = {obj.variables.name};
            end
        end
    end
end

