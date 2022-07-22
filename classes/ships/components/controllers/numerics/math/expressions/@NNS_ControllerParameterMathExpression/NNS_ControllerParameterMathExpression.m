classdef NNS_ControllerParameterMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        param NNS_ControllerComponentParameter
    end
    
    methods
        function obj = NNS_ControllerParameterMathExpression(param)
            obj.initExpr = '';
            obj.finalExpr = '';
            obj.intermExpres = {};

            obj.numInputs = 0;
            obj.inputs = NNS_ControllerMathExpression.empty(0,obj.numInputs);
            obj.param = param;
        end
        
        function str = getExpressionAsString(obj,getParamsAsNumerics)
            if(getParamsAsNumerics)
                str = num2str(obj.param.getValue(),30);
            else
                str = obj.param.getValueAsStr();
            end
            
            if(obj.isSelected)
                str = sprintf('<b>%s</b>', str);
            end
        end
    end
end