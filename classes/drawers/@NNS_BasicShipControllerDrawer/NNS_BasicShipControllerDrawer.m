classdef NNS_BasicShipControllerDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicShipHullDrawer Draws ships hulls in a basic way
    
    properties
        ship@NNS_PropagatedObject;
        controller@NNS_BasicShipController

        hP@matlab.graphics.primitive.Transform;
    end
    
    methods
        function obj = NNS_BasicShipControllerDrawer(ship, controller)
            obj.ship = ship;
            obj.controller = controller;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            if(obj.ship.active)   
                pos = obj.controller.getAbsPosition();
                
                if(isempty(obj.hP) || ~isgraphics(obj.hP))
                    hold(hAxes,'on');
                    obj.hP = hgtransform(hAxes);
                    obj.getPatchForControllerComponent(obj.hP);
                    hold(hAxes,'off');
                end
                
                M = makehgtform('translate',[pos(1) pos(2) 0]); 
                set(obj.hP,'Matrix',M);
            else
                obj.destroyGraphics();
            end
        end
        
        function p = getPatchForControllerComponent(obj, hgTransform)
            pgon = nsidedpoly(3,'Radius',obj.controller.getCompRadiusForPower());
            x = pgon.Vertices(:,1);
            y = pgon.Vertices(:,2);
            
            p = fill(x,y, 'c', 'FaceAlpha',1, 'EdgeColor','k', 'EdgeAlpha',1.0, 'Parent',hgTransform);
        end
        
        function destroyGraphics(obj)
            delete(obj.hP);
        end
        
        function patch = getPatchForDrawnComponents(obj)
            patch = obj.hP.Children(1);
        end
    end
end