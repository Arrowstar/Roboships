classdef NNS_HierarchyCategory < matlab.mixin.SetGet
    %NNS_HierarchyCategory Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name@char
    end
    
    methods
        function obj = NNS_HierarchyCategory(name)
            %NNS_HierarchyCategory Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = name;
        end
    end
end