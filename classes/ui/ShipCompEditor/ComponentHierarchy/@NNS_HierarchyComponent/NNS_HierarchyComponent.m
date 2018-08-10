classdef NNS_HierarchyComponent < matlab.mixin.SetGet
    %NNS_HierarchyComponent Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name@char
        category@NNS_HierarchyCategory
    end
    
    methods
        function obj = NNS_HierarchyComponent(name, category)
            %NNS_HierarchyComponent Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = name;
            obj.category = category;
        end
    end
end