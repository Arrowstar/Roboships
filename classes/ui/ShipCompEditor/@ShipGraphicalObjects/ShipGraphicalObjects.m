classdef ShipGraphicalObjects < matlab.mixin.SetGet 
    %ShipGraphicalObjects Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sPoly
        cPolys
        selectedPoly
        
        oldPos@double
        cPolyCompRefs@ShipGraphicalObjectsCompRefDictionary
        
        els@event.listener = event.listener.empty(0,0);
    end
    
    methods
        function obj = ShipGraphicalObjects()
            %ShipGraphicalObjects Construct an instance of this class
            %   Detailed explanation goes here
            
            obj.cPolys = impoly.empty(0,1);
            obj.oldPos = [0,0];
            
            obj.cPolyCompRefs = ShipGraphicalObjectsCompRefDictionary();
        end
        
        function setSPoly(obj,sPoly)
            obj.sPoly = sPoly;
            
            c = get(sPoly,'Children');
            pp = findall(c,'Type','patch');
            pp = pp(1);
            
            obj.oldPos = pp.Vertices;
        end
        
        function addCpoly(obj,cPoly,newComp)
            obj.cPolys(end+1) = cPoly;
            obj.cPolyCompRefs.addReference(cPoly, newComp);
        end
        
        function removeCpoly(obj,cPoly)
            obj.cPolyCompRefs.removeReference(cPoly);
            obj.cPolys(obj.cPolys == cPoly) = [];
        end
        
        function selComp = selectPoly(obj, selPoly)
            obj.selectedPoly = selPoly;
            selComp = obj.cPolyCompRefs.getCompForCpoly(selPoly);
            
            polys = [obj.sPoly, obj.cPolys];
            for(i=1:length(polys))
                poly = polys(i);
                pp = findall(poly,'Type','patch');
                pp = pp(1);
                
                if(selPoly == poly)
                    pp.LineWidth = 1.5;
                else
                    pp.LineWidth = 0.5;
                end
            end
        end
        
        function poly = getPolyForPoint(obj, point)
            poly = [];
            polyAndAreas = {};
            for(i=length(obj.cPolys):-1:1) %#ok<*NO4LP>
                cPoly = obj.cPolys(i);
                pp = findall(cPoly,'Type','patch');
                pp = pp(1);
                
                in = inpolygon(point(1),point(2),pp.Vertices(:,1),pp.Vertices(:,2));
                
                if(in)
                    polyAndAreas(end+1,:) = {cPoly, polyarea(pp.Vertices(:,1),pp.Vertices(:,2))}; %#ok<AGROW>
                end
            end
            
            if(not(isempty(polyAndAreas)))
                [~,I] = min([polyAndAreas{:,2}]);
                poly = polyAndAreas{I,1};
            end
            
            if(isempty(poly))
                pp = findall(obj.sPoly,'Type','patch');
                pp = pp(1);
                
                in = inpolygon(point(1),point(2),pp.Vertices(:,1),pp.Vertices(:,2));
                
                if(in)
                    poly = obj.sPoly;
                end
            end
        end
        
        function c = getSpolyCentroid(obj)
            c = obj.getCentroidOfImpoly(obj.sPoly);
        end
        
        function destroyAllListeners(obj)
            delete(obj.els);
            obj.els(not(isvalid(obj.els))) = [];
        end
    end
    
    methods(Static)
        function c = getCentroidOfImpoly(poly)
            c = ShipGraphicalObjects.getCentroidOfVertices(poly.getPosition());
        end
        
        function c = getCentroidOfVertices(verts)
            [cx, cy] = centroid(polyshape(verts));
            c = [cx, cy];
        end
    end
end

