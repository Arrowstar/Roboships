classdef ShipGraphicalObjectsCompRefDictionary < matlab.mixin.SetGet 
    %ShipGraphicalObjectsCompRefDictionary Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access=private)
        refs@ShipGraphicalObjectsCompReference
    end
    
    methods
        function obj = ShipGraphicalObjectsCompRefDictionary()
            %ShipGraphicalObjectsCompRefDictionary Construct an instance of this class
            %   Detailed explanation goes here
            obj.refs = ShipGraphicalObjectsCompReference.empty(0,0);
        end
        
        function addReference(obj, cPoly, newComp)
            obj.refs(end+1) = ShipGraphicalObjectsCompReference(cPoly, newComp);
        end
        
        function removeReference(obj, cPoly)
            for(i=1:length(obj.refs)) %#ok<*NO4LP>
                if(obj.refs(i).cPoly == cPoly)
                    obj.refs(obj.refs == obj.refs(i)) = [];
                    break;
                end
            end
        end
        
        function comp = getCompForCpoly(obj, cPoly)
            comp = NNS_VehicleComponent.empty(0,0);
            
            for(i=1:length(obj.refs)) %#ok<*NO4LP>
                if(obj.refs(i).cPoly == cPoly)
                    comp = obj.refs(i).comp;
                    break;
                end
            end
        end
        
        function cPoly = getCPolyForComp(obj, comp)
            cPoly = [];
            
            for(i=1:length(obj.refs))
                if(obj.refs(i).comp == comp)
                    cPoly = obj.refs(i).cPoly;
                    break;
                end
            end
        end
    end
end

