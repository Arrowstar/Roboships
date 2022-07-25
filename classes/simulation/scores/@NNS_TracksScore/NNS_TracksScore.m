classdef(Abstract = true) NNS_TracksScore < matlab.mixin.SetGet
    %NNS_TracksScore Interface for propagation objects that track their own
    %score
    
    properties
        
    end
    
    methods
        addPointsToScore(obj, newPoints);
        
        score = getCurrentScore(obj);
        
        playerName = getPlayerName(obj);
        
        health = getPlayerHealth(obj);
    end
end

