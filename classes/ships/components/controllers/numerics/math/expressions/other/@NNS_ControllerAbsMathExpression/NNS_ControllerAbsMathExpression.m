classdef NNS_ControllerAbsMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_ControllerAbsMathExpression()
            obj.initExpr = 'abs(';
            obj.finalExpr = ')';
            obj.intermExpres = {};

            obj.numInputs = 1;
            obj.setInputsToEmpty();
        end
    end
end