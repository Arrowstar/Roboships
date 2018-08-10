function [f] = trainNeuralNetObjFunc(x, ships, simDriver, scoreKeeper)
%trainNeuralNetObjFunc Summary of this function goes here
%   Detailed explanation goes here

    for(i=1:length(ships)) %#ok<*NO4LP>
        ships(i).setOptimizerVariables(x(i,:));
    end
    
    pgon2 = nsidedpoly(length(ships),'Center',[0 0],'SideLength',400);
    for(i=1:length(ships))
        simDriver.propObjs.removePropObj(ships(i));
        simDriver.propObjs.addPropagatedObject(ships(i));
        
        p = pgon2.Vertices(i,:)';
        ships(i).stateMgr.position = p;
        [theta,~] = cart2pol(p(1),p(2));
        ships(i).stateMgr.heading = angleZero2Pi(theta+pi);
    end
    
    scoreKeeper.resetScores();
    simDriver.driveSimulation();
%     scoreKeeper.printOutScores();
    
    f = zeros([1, size(x,1)]);
    for(i=1:length(ships)) %#ok<*NO4LP>
        f(i) = -ships(i).getCurrentScore();
    end
end

