classdef NNS_ControllerCosineMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_ControllerCosineMathExpression()
            obj.initExpr = 'cosd(';
            obj.finalExpr = ')';
            obj.intermExpres = {};

            obj.numInputs = 1;
            obj.setInputsToEmpty();
        end
    end
end