classdef NNS_BasicActiveSensorDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_BasicActiveSensorDrawer Summary of this class goes here
    
    properties
        ship@NNS_PropagatedObject;
        sensor@NNS_BasicActiveSensor;
        hP@matlab.graphics.primitive.Transform;
        hCP@matlab.graphics.primitive.Transform;
    end
    
    methods
        function obj = NNS_BasicActiveSensorDrawer(ship, sensor)
            %NNS_BasicActiveSensorDrawer Construct an instance of this class
            obj.ship = ship;
            obj.sensor = sensor;

            addlistener(obj.sensor,'curConeAngle','PostSet',@obj.updateSensorArcOnPwrAngleChange);
        end
       
        function drawObjectOnAxes(obj, hAxes)    
            if(obj.ship.active)
                pos       = obj.sensor.getAbsPosition();
                pntingAng = obj.sensor.getAbsPntingAngle();

                if(isempty(obj.hP) || ~isgraphics(obj.hP))
                    hold(hAxes,'on');
                    obj.hP = hgtransform(hAxes);
                    getPatchForSensorCone(obj, obj.hP);
                    hold(hAxes,'off');
                end
                
                if(isempty(obj.hCP) || ~isgraphics(obj.hCP))
                    hold(hAxes,'on');
                    obj.hCP = hgtransform(hAxes);
                    getPatchForSensorComponent(obj, obj.hCP);
                    hold(hAxes,'off');
                end

                if(obj.sensor.sensorHasDetectedSomething())
                    obj.hP.Children(1).EdgeColor = 'r';
                else
                    obj.hP.Children(1).EdgeColor = 'k';
                end
                
                M = makehgtform('translate',[pos(1) pos(2) 0], 'zrotate',pntingAng); 
                set(obj.hP,'Matrix',M);
                
                M = makehgtform('translate',[pos(1) pos(2) 0]); 
                set(obj.hCP,'Matrix',M);
            else
                obj.destroyGraphics();
            end
        end
        
        function destroyGraphics(obj)
            delete(obj.hP);
            delete(obj.hCP);
        end
        
        function [x,y] = getPtsForSensorConePatch(obj)
            rad       = obj.sensor.maxRng;
            coneAng   = obj.sensor.curConeAngle;
            
            [x,y] = plot_arc(0-coneAng/2, 0+coneAng/2, 0, 0, rad);
        end
        
        function updateSensorArcOnPwrAngleChange(obj,~,~)
            if(~isempty(obj.hP) && isgraphics(obj.hP))
                [x,y] = obj.getPtsForSensorConePatch();
                set(obj.hP.Children(1), 'XData',x,'YData',y);
            end
        end
        
        function p = getPatchForSensorCone(obj, hgTransform)
            [x,y] = obj.getPtsForSensorConePatch();
            p = fill(x,y, 'g', 'FaceAlpha',0.3, 'EdgeColor','k', 'EdgeAlpha',1.0, 'Parent',hgTransform);
        end
        
        function p = getPatchForSensorComponent(obj, hgTransform)
            pgon = nsidedpoly(8,'Radius',obj.sensor.getCompRadiusForPower());
            x = pgon.Vertices(:,1);
            y = pgon.Vertices(:,2);
            
            p = fill(x,y, [152,251,152]/255, 'FaceAlpha',1, 'EdgeColor','k', 'EdgeAlpha',1.0, 'Parent',hgTransform);
        end
        
        function patch = getPatchForDrawnComponents(obj)
            patch = obj.hCP.Children(1);
        end
    end
end

function [x,y] = plot_arc(a,b,h,k,r)
    % Plot a circular arc as a pie wedge.
    % a is start of arc in radians, 
    % b is end of arc in radians, 
    % (h,k) is the center of the circle.
    % r is the radius.
    % Try this:   plot_arc(pi/4,3*pi/4,9,-4,3)
    % Author:  Matt Fig

    n = ceil(rad2deg(b-a)/12);
    if(n < 3)
        n = 3;
    end
    
    t = linspace(a,b,n);
    x = r*cos(t) + h;
    y = r*sin(t) + k;
    
    x = [x h x(1)]';
    y = [y k y(1)]';  
end

