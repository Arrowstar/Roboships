classdef NNS_ControllerRandMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_ControllerRandMathExpression()
            obj.initExpr = 'rand(';
            obj.finalExpr = ')';
            obj.intermExpres = {};

            obj.numInputs = 0;
            obj.setInputsToEmpty();
        end
    end
end