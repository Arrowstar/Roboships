classdef NNS_RandomShipPlacement < NNS_AbstractInitialShipPlacement
    %NNS_RandomShipPlacement Summary of this class goes here
    %   Detailed explanation goes here

    properties
        
    end

    methods
        function obj = NNS_RandomShipPlacement()
            
        end

        function setInitialShipLocation(obj, ships, arena)
            arguments
                obj(1,1) NNS_RandomShipPlacement
                ships NNS_Ship
                arena(1,1) NNS_Arena
            end

            for(i=1:length(ships)) %#ok<*NO4LP> 
                ships(i).stateMgr.setRandomizedPositionAndHeading([arena.xLims, arena.yLims], [0 360]);
            end
        end
    end
end