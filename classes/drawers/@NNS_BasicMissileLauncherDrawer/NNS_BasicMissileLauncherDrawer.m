classdef NNS_BasicMissileLauncherDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicShipHullDrawer Draws ships hulls in a basic way
    
    properties
        ship@NNS_Ship;
        missleLauncher@NNS_BasicMissileLauncher

        hP@matlab.graphics.primitive.Transform;
        hL@matlab.graphics.primitive.Line;
    end
    
    methods
        function obj = NNS_BasicMissileLauncherDrawer(ship, missleLauncher)
            %NNS_BasicShipHullDrawer Construct an instance of this class
            obj.ship = ship;
            obj.missleLauncher = missleLauncher;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            if(obj.ship.active)   
                pos = obj.missleLauncher.getAbsPosition();
                pntAng = obj.missleLauncher.getAbsPntingAngle();
                charSize = obj.missleLauncher.getCharacteristicSizeForComp();
                [x,y] = pol2cart(pntAng,2*charSize);
                
                if(isempty(obj.hP) || ~isgraphics(obj.hP))
                    hold(hAxes,'on');
                    obj.hP = hgtransform(hAxes);
                    obj.getPatchForGunComponent(obj.hP);
                    hold(hAxes,'off');
                end
                
                if(isempty(obj.hL) || ~isgraphics(obj.hL))
                    obj.hL = line(hAxes, [0 0], [0 0], 'Color',[169,169,169]/255, 'LineWidth',1.5);
                end

                obj.hL.XData = [pos(1), pos(1) + x];
                obj.hL.YData = [pos(2), pos(2) + y];
                
                M = makehgtform('translate',[pos(1) pos(2) 0], 'zrotate',pntAng); 
                set(obj.hP,'Matrix',M);
            else
                obj.destroyGraphics();
            end
        end
        
        function p = getPatchForGunComponent(obj, hgTransform)
            charSize = obj.missleLauncher.getCharacteristicSizeForComp();
            verts = [1/3, -1.0;
                     1/3, -1/3;
                     1/2, -1/3;
                     1/2,  1/3;
                     1/3,  1/3;
                     1/3,  1.0;
                     -1/3, 1.0;
                     -1/3, 1/3;
                     -1/2, 1/3;
                     -1/2, -1/3;
                     -1/3, -1/3;
                     -1/3, -1.0];
            verts = 2*charSize.*verts./1.3;
            
            x = verts(:,2);
            y = verts(:,1);
            
            p = fill(x,y, [250,128,114]/255, 'FaceAlpha',1, 'EdgeColor','k', 'EdgeAlpha',1.0, 'Parent',hgTransform);
        end
        
        function destroyGraphics(obj)
            delete(obj.hP);
            delete(obj.hL);
        end
        
        function patch = getPatchForDrawnComponents(obj)
            patch = obj.hP.Children(1);
        end
    end
end