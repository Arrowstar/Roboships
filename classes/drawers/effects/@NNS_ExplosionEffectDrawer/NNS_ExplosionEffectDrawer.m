classdef NNS_ExplosionEffectDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicPropjectileDrawer Draws the basic projectile onto the axes
    
    properties
        effect NNS_ExplosionEffect;
        
        %projectile graphic object
        hC matlab.graphics.primitive.Transform
        hR matlab.graphics.primitive.Rectangle
    end
    
    methods
        function obj = NNS_ExplosionEffectDrawer(effect)
            %NNS_BasicPropjectileDrawer Construct an instance of this class
            obj.effect = effect;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            if(obj.effect.active)
                pos = obj.effect.stateMgr.position;
                radius = obj.effect.curRadius;
                initR = obj.effect.initialRadius;
                finR = obj.effect.finalRadius;
                s = radius/initR;
                
                if(isempty(obj.hC) || ~isgraphics(obj.hC))
                    obj.hC = hgtransform(hAxes);
                    obj.hR = rectangle(hAxes, 'Position',[0,0, 2*initR, 2*initR], 'Curvature',[1 1], 'FaceColor','r', ...
                                              'Parent',obj.hC);
                end

                newColor = (obj.effect.initColor*(finR-radius) + obj.effect.finalColor*(radius-initR))/(finR-initR);
                set(obj.hR,'FaceColor',newColor);
                
                M = makehgtform('translate',[pos(1)-radius pos(2)-radius 0], 'scale',[s, s, 1]); 
                set(obj.hC,'Matrix',M);
            else
                obj.destroyGraphics();
            end
        end
        
        function destroyGraphics(obj)
            delete(obj.hC);
            delete(obj.hR);
        end
    end
end