classdef NNS_CommandConnectionTracker < matlab.mixin.SetGet    
    
    properties
        elements NNS_CommandConnectionTrackerElement
    end
    
    methods
        function obj = NNS_CommandConnectionTracker()
            obj.elements = NNS_CommandConnectionTrackerElement.empty(0,0);
        end
        
        function addConnection(obj, circPoly, fromCmd, toCmd, id)
            obj.elements(end+1) = NNS_CommandConnectionTrackerElement(circPoly, fromCmd, toCmd, id);
        end
        
        function conns = getConnectionsToCmd(obj, toCmd)
            conns = findobj(obj.elements, 'toCmd',toCmd);
        end
        
        function removeConnection(obj, fromCmd, toCmd)
            h = findobj(obj.elements, 'fromCmd',fromCmd, 'toCmd',toCmd);
            if(not(isempty(h)))
                obj.elements(obj.elements == h) = [];
            end
        end
    end
end