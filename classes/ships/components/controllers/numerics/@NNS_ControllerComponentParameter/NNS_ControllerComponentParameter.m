classdef (Abstract) NNS_ControllerComponentParameter < NNS_ControllerNumeric & NNS_CmdListboxEntry
    %NNS_ControllerComponentParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Abstract)
        paramName@char
    end

    methods(Abstract)
        comp = getComponent(obj);                
    end
end

