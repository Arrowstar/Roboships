classdef NNS_BasicPowerGeneratorDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicPowerGeneratorDrawer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ship NNS_Ship;
        pwrGen NNS_BasicPowerGenerator
        hP matlab.graphics.primitive.Transform;
    end
    
    methods
        function obj = NNS_BasicPowerGeneratorDrawer(ship, pwrGen)
            obj.ship = ship;
            obj.pwrGen = pwrGen;
        end
        
        function drawObjectOnAxes(obj, hAxes)    
            if(obj.ship.active)
                pos       = obj.pwrGen.getAbsPosition();

                if(isempty(obj.hP) || ~isgraphics(obj.hP))
                    hold(hAxes,'on');
                    obj.hP = hgtransform(hAxes);
                    getPatchForPwrComponent(obj, obj.hP);
                    hold(hAxes,'off');
                end
                
                M = makehgtform('translate',[pos(1) pos(2) 0]); 
                set(obj.hP,'Matrix',M);
            else
                obj.destroyGraphics();
            end
        end        
        
        function destroyGraphics(obj)
            delete(obj.hP);
        end
        
        function patch = getPatchForDrawnComponents(obj)
            patch = obj.hP.Children(1);
        end

        function p = getPatchForPwrComponent(obj, hgTransform)
            pgon = nsidedpoly(20,'Radius',obj.pwrGen.getCompRadiusForPower());
            x = pgon.Vertices(:,1);
            y = pgon.Vertices(:,2);
            
            p = fill(x,y, [240,230,140]/255, 'FaceAlpha',1, 'EdgeColor','k', 'EdgeAlpha',1.0, 'Parent',hgTransform);
        end
    end
end

