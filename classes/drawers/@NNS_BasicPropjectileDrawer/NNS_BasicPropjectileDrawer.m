classdef NNS_BasicPropjectileDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicPropjectileDrawer Draws the basic projectile onto the axes
    
    properties
        marker@char = '.';
        projectile@NNS_BasicProjectile;
        
        %projectile graphic object
        hP@matlab.graphics.primitive.Line
    end
    
    methods
        function obj = NNS_BasicPropjectileDrawer(projectile)
            %NNS_BasicPropjectileDrawer Construct an instance of this class
            obj.projectile = projectile;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            if(obj.projectile.active)
                pos = obj.projectile.stateMgr.position;

                if(isempty(obj.hP) || ~isgraphics(obj.hP))
                    obj.hP = line(hAxes, [0], [0], 'Color','k', 'Marker',obj.marker);
                end

                obj.hP.XData = pos(1);
                obj.hP.YData = pos(2);
            else
                obj.destroyGraphics();
            end
        end
        
        function destroyGraphics(obj)
            delete(obj.hP);
        end
    end
end