classdef NNS_BasicMineLayerDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicShipHullDrawer Draws ships hulls in a basic way
    
    properties
        ship@NNS_Ship;
        gun@NNS_BasicMineLayer

        hP@matlab.graphics.primitive.Transform;
    end
    
    methods
        function obj = NNS_BasicMineLayerDrawer(ship, gun)
            obj.ship = ship;
            obj.gun = gun;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            if(obj.ship.active)   
                pos = obj.gun.getAbsPosition();
                
                if(isempty(obj.hP) || ~isgraphics(obj.hP))
                    hold(hAxes,'on');
                    obj.hP = hgtransform(hAxes);
                    obj.getPatchForGunComponent(obj.hP);
                    hold(hAxes,'off');
                end
                
                M = makehgtform('translate',[pos(1) pos(2) 0]); 
                set(obj.hP,'Matrix',M);
            else
                obj.destroyGraphics();
            end
        end
        
        function p = getPatchForGunComponent(obj, hgTransform)
            pgon = nsidedpoly(4,'Radius',obj.gun.getCompRadiusForPower());
            x = pgon.Vertices(:,1);
            y = pgon.Vertices(:,2);
            
            p = fill(x,y, [250,128,114]/255, 'FaceAlpha',1, 'EdgeColor','k', 'EdgeAlpha',1.0, 'Parent',hgTransform);
        end
        
        function destroyGraphics(obj)
            delete(obj.hP);
        end
        
        function patch = getPatchForDrawnComponents(obj)
            patch = obj.hP.Children(1);
        end
    end
end