classdef NNS_ControllerConstantMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        const@NNS_ControllerConstant
    end
    
    methods
        function obj = NNS_ControllerConstantMathExpression(const)
            obj.initExpr = '';
            obj.finalExpr = '';
            obj.intermExpres = {};

            obj.numInputs = 0;
            obj.inputs = NNS_ControllerMathExpression.empty(0,obj.numInputs);
            
            if(isa(const,'double'))
                obj.const = NNS_ControllerConstant(const);
            else
                obj.const = const;
            end
            
        end
        
        function str = getExpressionAsString(obj, ~)
            str = obj.const.getValueAsStr();
            
            if(obj.isSelected)
                str = sprintf('<b>%s</b>', str);
            end
        end
    end
end