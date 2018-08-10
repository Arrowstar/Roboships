classdef NNS_ControllerAdditionMathExpression < NNS_ControllerMathExpression
    %NNS_ControllerEmptyMathExpression Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = NNS_ControllerAdditionMathExpression()
            obj.initExpr = '';
            obj.finalExpr = '';
            obj.intermExpres = {' + '};

            obj.numInputs = 2;
            obj.setInputsToEmpty();
        end
    end
end