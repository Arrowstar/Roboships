classdef (Abstract) NNS_NeuralNetworkCapable < matlab.mixin.SetGet 
    
    properties
        
    end
    
    methods
        obsInfo = getObservationInfo(obj)
        obs = getObservation(obj)

        actInfo = getActionInfo(obj)
        execAction(obj);
    end
end