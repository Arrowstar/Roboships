classdef NNS_CircularShipPlacement < matlab.mixin.SetGet
    %NNS_CircularShipPlacement Summary of this class goes here
    %   Detailed explanation goes here

    properties
        
    end

    methods
        function obj = NNS_CircularShipPlacement()
            
        end

        function setInitialShipLocation(obj, ships, arena)
            arguments
                obj(1,1) NNS_CircularShipPlacement
                ships NNS_Ship
                arena(1,1) NNS_Arena
            end

            numShips = numel(ships);

            xWidth = max(arena.xLims) - min(arena.xLims);
            yWidth = max(arena.yLims) - min(arena.yLims);
            minWidth = min([xWidth, yWidth])/4;

            xCenter = mean(arena.xLims);
            yCenter = mean(arena.yLims);

            theta=linspace(0,360,numShips+1) + 45; 
            theta(end)=[];
            xs=minWidth*cosd(theta) + xCenter;
            ys=minWidth*sind(theta) + yCenter;

            for(i=1:numel(ships)) %#ok<*NO4LP> 
                ship = ships(i);

                ship.stateMgr.position = [xs(i); ys(i)];
                ship.stateMgr.velocity = [0; 0];
                ship.stateMgr.heading = angleZero2Pi(deg2rad(theta(i)) + pi);
                ship.stateMgr.angRate = 0;
            end
        end
    end
end