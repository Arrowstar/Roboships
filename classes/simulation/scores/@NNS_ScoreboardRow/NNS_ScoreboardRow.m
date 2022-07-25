classdef NNS_ScoreboardRow < matlab.mixin.SetGet
    %NNS_ScoreboardRow Tracks the score of one player
    
    properties
        player NNS_PropagatedObject
        score double = 0;
    end
    
    methods
        function obj = NNS_ScoreboardRow(player)
            %NNS_ScoreboardRow Construct an instance of this class
            obj.player = player;
        end
        
        function addToScore(obj, newPoints)
            obj.score = obj.score + newPoints;
        end
        
        function score = getScore(obj)
            score = obj.score;
        end
        
    end
end

