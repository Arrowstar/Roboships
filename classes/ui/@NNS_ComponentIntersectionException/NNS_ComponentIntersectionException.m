classdef NNS_ComponentIntersectionException < matlab.mixin.SetGet
    %NNS_ComponentIntersectionException Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        compClass1 char
        compClass2 char
    end
    
    methods
        function obj = NNS_ComponentIntersectionException(compClass1,compClass2)
            obj.compClass1 = compClass1;
            obj.compClass2 = compClass2;
        end
    end
end

