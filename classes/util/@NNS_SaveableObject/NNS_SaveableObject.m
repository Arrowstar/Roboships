classdef (Abstract) NNS_SaveableObject < matlab.mixin.SetGet 
    
    properties
        savedToPath char = '';
        changed logical = false;
    end
    
    methods
        
    end
end