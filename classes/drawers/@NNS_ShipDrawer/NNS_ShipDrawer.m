classdef NNS_ShipDrawer < NNS_AbstractPropagatedObjectDrawer
    %NNS_PropagatedObjectDrawer Summary of this class goes here
    
    properties
        rectWidth@double = 20; %meter
        rectHgt@double   = 10; %meter
        ship@NNS_Ship;
    end
    
    methods
        function obj = NNS_ShipDrawer(ship)
            %NNS_PropagatedObjectDrawer Construct an instance of this class
            obj.ship = ship;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            obj.ship.hull.drawObjectOnAxes(hAxes);
            
            compsList = obj.ship.components.getDrawableComponents();
            
            for(i=1:length(compsList)) %#ok<*NO4LP>
                compsList(i).drawObjectOnAxes(hAxes);
            end
        end
        
        function destroyGraphics(obj)
            compsList = obj.ship.components.components();
            
            for(i=1:length(compsList)) %#ok<*NO4LP>
                comp = compsList(i);
                if(isa(comp,'NNS_AbstractDrawableVehicleComponent'))
                    comp.destroyGraphics();
                end
            end
        end
    end
end