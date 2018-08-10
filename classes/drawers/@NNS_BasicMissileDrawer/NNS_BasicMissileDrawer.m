classdef NNS_BasicMissileDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_PropagatedObjectDrawer Summary of this class goes here
    
    properties
        missile@NNS_BasicMissile;
    end
    
    methods
        function obj = NNS_BasicMissileDrawer(missile)
            %NNS_PropagatedObjectDrawer Construct an instance of this class
            obj.missile = missile;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            obj.missile.hull.drawObjectOnAxes(hAxes);
            
%             compsList = obj.missile.components.getDrawableComponents();
%             
%             for(i=1:length(compsList)) %#ok<*NO4LP>
%                 compsList(i).drawObjectOnAxes(hAxes);
%             end
        end
        
        function destroyGraphics(obj)
            compsList = obj.missile.components.components();
            
            for(i=1:length(compsList)) %#ok<*NO4LP>
                comp = compsList(i);
                if(isa(comp,'NNS_AbstractDrawableVehicleComponent'))
                    comp.destroyGraphics();
                end
            end
        end
    end
end