classdef NNS_ControllerEmptyMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_ControllerEmptyMathExpression()
            obj.initExpr = ' ? ';
            obj.finalExpr = '';
            obj.intermExpres = {};

            obj.numInputs = 0;
        end
    end
end