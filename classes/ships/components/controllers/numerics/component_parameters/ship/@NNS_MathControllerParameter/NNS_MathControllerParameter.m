classdef NNS_MathControllerParameter < NNS_ControllerComponentParameter
    %NNS_ConstantControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship@NNS_PropagatedObject
        paramName@char = 'Math';
        
        math@NNS_ControllerMathExpression
    end
    
    methods
        function obj = NNS_MathControllerParameter(ship)
            obj.ship = ship;
            obj.math = NNS_ControllerEmptyMathExpression();
        end
        
        function value = getValue(obj)
            value = eval(obj.math.getExpressionAsString(true)); 
        end
        
        function str = getValueAsStr(obj)
            str = obj.math.getExpressionAsString(false);
        end
        
        function comp = getComponent(obj)
            comp = obj.ship;
        end
        
        function setConstValue(obj, newValue)
            obj.constant.value = newValue;
        end
        
        function selExpr = getSelectedExpr(obj)
            selExpr = NNS_ControllerMathExpression.empty(0,0);
            
            sETable = obj.math.getStartEndIndicesTable(1,{});
            for(i=1:size(sETable,1)) %#ok<*NO4LP>
                if(sETable{i,1}.isSelected == true)
                    selExpr = sETable{i,1};
                    
                    break;
                end
            end
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Math';
        end
    end
end