classdef NNS_ControllerVariableMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        var@NNS_ControllerVariable
    end
    
    methods
        function obj = NNS_ControllerVariableMathExpression(var)
            obj.initExpr = '';
            obj.finalExpr = '';
            obj.intermExpres = {};

            obj.numInputs = 0;
            obj.inputs = NNS_ControllerMathExpression.empty(0,obj.numInputs);
            obj.var = var;
        end
        
        function str = getExpressionAsString(obj,getParamsAsNumerics)
            if(getParamsAsNumerics)
                str = num2str(obj.var.getValue(),30);
            else
                str = obj.var.getValueAsStr();
            end
            
            if(obj.isSelected)
                str = sprintf('<b>%s</b>', str);
            end
        end
    end
end