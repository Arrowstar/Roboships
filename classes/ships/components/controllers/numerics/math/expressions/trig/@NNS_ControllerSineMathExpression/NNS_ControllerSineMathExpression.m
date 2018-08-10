classdef NNS_ControllerSineMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_ControllerSineMathExpression()
            obj.initExpr = 'sind(';
            obj.finalExpr = ')';
            obj.intermExpres = {};

            obj.numInputs = 1;
            obj.setInputsToEmpty();
        end
    end
end