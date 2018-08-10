classdef NNS_ControllerHypotMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_ControllerHypotMathExpression()
            obj.initExpr = 'hypot(';
            obj.finalExpr = ')';
            obj.intermExpres = {','};

            obj.numInputs = 2;
            obj.setInputsToEmpty();
        end
    end
end