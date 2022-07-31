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

            numShips = numel(ships);

            xWidth = max(arena.xLims) - min(arena.xLims);
            yWidth = max(arena.yLims) - min(arena.yLims);
            minDist = min([xWidth, yWidth])/numShips;

            xCenter = mean(arena.xLims);
            yCenter = mean(arena.yLims);

            [xs, ys] = GetPointsRandom(numShips, xWidth, yWidth, minDist);
            xs = xs - xWidth/2 + xCenter;
            ys = ys - yWidth/2 + yCenter;

            for(i=1:numShips) %#ok<*NO4LP>
                ship = ships(i);

                ship.stateMgr.position = [xs(i); ys(i)];
                ship.stateMgr.velocity = [0; 0];
                ship.stateMgr.heading = 2*pi*rand();
                ship.stateMgr.angRate = 0;

                pid = ship.basicPropagator.headingCntrlr;
                pid.setPIDParam(pid.PID_SETPOINT, angleZero2Pi(ship.stateMgr.heading));

                pid = ship.basicPropagator.speedCntrlr;
                pid.setPIDParam(pid.PID_SETPOINT, 0);
            end
        end
    end
end

function [X, Y, D] = GetPointsRandom(nWant, XWidth, YWidth, MinDist)
    X       = zeros(nWant, 1);
    Y       = zeros(nWant, 1);
    dist_2  = MinDist ^ 2;      % Squared once instead of SQRT each time
    iLoop   = 1;                % Security break to yoid infinite loop
    nValid  = 0;
    while nValid < nWant && iLoop < 1e6
        newX = XWidth * rand;
        newY = YWidth * rand;
        if all(((X(1:nValid) - newX).^2 + (Y(1:nValid) - newY).^2) >= dist_2)
            % Success: The new point does not touch existing points:
            nValid    = nValid + 1;  % Append this point
            X(nValid) = newX;
            Y(nValid) = newY;
        end
        iLoop = iLoop + 1;
    end
    % Throw an error, if the area is filled too densely:
    if nValid < nWant
        error('Cannot find wanted number of points in %d iterations.', iLoop)
    end
    if nargout > 2
        % D = pdist([X, Y]);   % Faster with statistics toolbox
        D = sqrt(bsxfun(@minus, X, X.') .^ 2 + bsxfun(@minus, Y, Y.') .^ 2);
    end
end