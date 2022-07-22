classdef (Abstract) NNS_ControllerMathExpression < matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    %NNS_ControllerMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        initExpr char
        finalExpr char
        intermExpres cell %cell array with one or more intermidiate things
        
        numInputs double; 
        inputs NNS_ControllerMathExpression
        parent NNS_ControllerMathExpression
        
        isSelected logical = false;
    end
    
    methods
        function setInputsToEmpty(obj)
            obj.inputs = NNS_ControllerMathExpression.empty(0,obj.numInputs);
            for(i=1:obj.numInputs)
                obj.inputs(i) = NNS_ControllerEmptyMathExpression();
                obj.inputs(i).parent = obj;
            end
        end
        
        function setInput(obj, newInput, ind)
            obj.inputs(ind) = newInput;
            newInput.parent = obj;
        end
        
        function setIntermediateExpr(obj, newIntermediate, ind)
            obj.intermExpres{ind} = newIntermediate;
        end
        
        function strLen = getLengthOfExprInit(obj)
            strLen = length(obj.initExpr);
        end

        function strLen = getLengthOfExprFinal(obj)
            strLen = length(obj.finalExpr);
        end
        
        function strLen = getLengthOfIntermediate(obj,intermediateInd)
            strLen = length(obj.intermExpres{intermediateInd});
        end        
        
        function str = getExpressionAsString(obj, getParamsAsNumerics)          
            str = obj.initExpr;
            
            for(i=1:obj.numInputs)
                str = [str,obj.inputs(i).getExpressionAsString(getParamsAsNumerics)]; %#ok<AGROW> %no need to nest highlighted 
                if(i < obj.numInputs)
                    str = [str,obj.intermExpres{i}];               %#ok<AGROW>
                end
            end
            
            str = [str, obj.finalExpr];
            
            if(obj.isSelected && getParamsAsNumerics == false)
                str = sprintf('<b>%s</b>', str);
            end
        end
        
        function strLen = getLengthOfExpression(obj)
            strLen = length(obj.getExpressionAsString(false));
        end
        
        function [existingTable] = getStartEndIndicesTable(obj, startInd, existingTable)
            endInd = startInd + obj.getLengthOfExpression();
            
            existingTable(end+1,:) = {obj, startInd, endInd, endInd-startInd};
            
            inputStart = obj.getLengthOfExprInit() + startInd; 
            for(i=1:length(obj.inputs))
                existingTable = obj.inputs(i).getStartEndIndicesTable(inputStart, existingTable);
                
                inputStart = inputStart + obj.inputs(i).getLengthOfExpression();  
                if(i < obj.numInputs)
                    inputStart = inputStart + obj.getLengthOfIntermediate(i);
                end
            end
        end
        
        function setSelectedState(obj, selState)
            for(i=1:obj.numInputs)
                obj.inputs(i).setSelectedState(false);
            end
            
            obj.isSelected = selState;
        end
        
        function tf = isExpressionValid(obj)
            tf = not(isa(obj,'NNS_ControllerEmptyMathExpression'));
            
            for(i=1:obj.numInputs) %#ok<*NO4LP>
                if(isempty(obj.inputs(i)) || isa(obj.inputs(i),'NNS_ControllerEmptyMathExpression'))
                    tf = false;
                end
            end
            
            for(i=1:obj.numInputs) %#ok<*NO4LP>
                tf = tf && obj.inputs(i).isExpressionValid();
            end
        end
    end
end

