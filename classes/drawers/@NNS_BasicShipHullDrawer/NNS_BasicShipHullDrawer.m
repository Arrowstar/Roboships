classdef NNS_BasicShipHullDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicShipHullDrawer Draws ships hulls in a basic way
    
    properties
        ship NNS_PropagatedObject;
        hull NNS_BasicShipHull;
        
        hH matlab.graphics.primitive.Transform;
        hL matlab.graphics.primitive.Line;
    end
    
    methods
        function obj = NNS_BasicShipHullDrawer(ship, hull)
            %NNS_BasicShipHullDrawer Construct an instance of this class
            obj.ship = ship;
            obj.hull = hull;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            if(obj.ship.active)
                rectWidth = abs(max(obj.hull.hullVerts(:,1)) - min(obj.hull.hullVerts(:,1)));

                pos = obj.ship.stateMgr.position;
                heading = obj.ship.stateMgr.heading;
                hdgVect = 2*rectWidth*normVector(obj.ship.stateMgr.velocity());

                if(isempty(obj.hH) || ~isgraphics(obj.hH))
                    hold on;
                    obj.hH = hgtransform(hAxes);
                    drawBaseHull(obj, obj.hH);
                    hold off;
                end
                
                M = makehgtform('translate',[pos(1) pos(2) 0], 'zrotate',heading); 
                set(obj.hH,'Matrix',M);

                if(isempty(obj.hL) || ~isgraphics(obj.hL))
                    obj.hL = line(hAxes, [0 0], [0 0], 'Color', 'r');
                end

                obj.hL.XData = [pos(1), pos(1) + hdgVect(1)];
                obj.hL.YData = [pos(2), pos(2) + hdgVect(2)];
            else
                obj.destroyGraphics();
            end
        end
        
        function destroyGraphics(obj)
            delete(obj.hH);
            delete(obj.hL);
        end
        
        function drawBaseHull(obj, hgTransform)
            hullVerts = obj.hull.getHullVertices();
            c = ShipGraphicalObjects.getCentroidOfVertices(hullVerts);
            hullVerts = hullVerts - c;
            fill(hullVerts(:,1),hullVerts(:,2), [211,211,211]/255, 'EdgeColor','k', 'Parent',hgTransform);
        end
    end
end

