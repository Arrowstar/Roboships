classdef NNS_ComponentIntersectionExceptionSet < matlab.mixin.SetGet
    %NNS_ComponentIntersectionExceptionSet Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        exceptions NNS_ComponentIntersectionException
    end
    
    methods
        function obj = NNS_ComponentIntersectionExceptionSet()
            obj.exceptions = NNS_ComponentIntersectionException.empty(0,0);
        end
        
        function hasException = hasIntersectionException(obj, comp1, comp2)
            hasException = false;
            
            for(i=1:length(obj.exceptions)) %#ok<*NO4LP>
                exception = obj.exceptions(i);
                
                if((isa(comp1, exception.compClass1) && ...
                    isa(comp2, exception.compClass2)) || ...
                   (isa(comp1, exception.compClass2) && ...
                    isa(comp2, exception.compClass1)))
               
                    hasException = true;
                    break;
                end
            end
        end
    end
    
    methods(Static)
        function exSet = getDefaultComponentIntersectionExceptionSet()
            exSet = NNS_ComponentIntersectionExceptionSet();
            
            ex = NNS_ComponentIntersectionException('NNS_AbstractGun', 'NNS_AbstractSensor');
            exSet.exceptions(end+1) = ex;
        end
    end
end

