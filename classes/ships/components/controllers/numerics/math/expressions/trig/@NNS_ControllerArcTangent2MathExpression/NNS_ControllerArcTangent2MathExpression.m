classdef NNS_ControllerArcTangent2MathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_ControllerArcTangent2MathExpression()
            obj.initExpr = 'atan2d(';
            obj.finalExpr = ')';
            obj.intermExpres = {','};

            obj.numInputs = 2;
            obj.setInputsToEmpty();
        end
    end
end