classdef NNS_BasicMineDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicMineDrawer Draws the basic projectile onto the axes
    
    properties
        marker@char = '.';
        mine@NNS_BasicMine;
        
        %projectile graphic object
        hP@matlab.graphics.primitive.Line
        hL@matlab.graphics.primitive.Transform
        hR@matlab.graphics.primitive.Rectangle
    end
    
    methods
        function obj = NNS_BasicMineDrawer(mine)
            obj.mine = mine;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            if(obj.mine.active)
                pos = obj.mine.stateMgr.position;
                effRng = obj.mine.effectiveRng;
                
                if(isempty(obj.hP) || ~isgraphics(obj.hP))
                    obj.hP = line(hAxes, [0], [0], 'Color','k', 'Marker',obj.marker);
                end

                obj.hP.XData = pos(1);
                obj.hP.YData = pos(2);
                
                if(isempty(obj.hL) || ~isgraphics(obj.hL))
                    hold(hAxes,'on');
                    obj.hL = hgtransform(hAxes);
                    obj.hR = rectangle(hAxes, 'Position',[-effRng/2, -effRng/2, effRng, effRng], 'Curvature',[1 1], 'FaceColor',[0 0 0 0], ...
                                              'EdgeColor','g', 'Parent',obj.hL);
                    hold(hAxes,'off');
                end
                
                if(obj.mine.isMineArmed())
                    obj.hR.EdgeColor = 'r';
                end
                
                M = makehgtform('translate',[pos(1) pos(2) 0]); 
                set(obj.hL,'Matrix',M);
            else
                obj.destroyGraphics();
            end
        end
        
        function destroyGraphics(obj)
            delete(obj.hP);
            delete(obj.hL);
        end
    end
end