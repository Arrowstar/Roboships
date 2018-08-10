classdef NNS_CommandConnectionTrackerElement < matlab.mixin.SetGet    
    
    properties
        circPoly@imellipse
        fromCmd@NNS_AbstractControllerOperation
        toCmd@NNS_AbstractControllerOperation
        id@struct
    end
    
    methods
        function obj = NNS_CommandConnectionTrackerElement(circPoly, fromCmd, toCmd, id)
            obj.circPoly = circPoly;
            obj.fromCmd = fromCmd;
            obj.toCmd = toCmd;
            obj.id = id;
        end
    end
end