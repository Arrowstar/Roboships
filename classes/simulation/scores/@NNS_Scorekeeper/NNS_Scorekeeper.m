classdef NNS_Scorekeeper < matlab.mixin.SetGet
    %NNS_Scorekeeper This class is responsible for keeping 'score' over the
    %course of a simulation.
    
    properties
        scoreBoardRows(1,:) NNS_ScoreboardRow
    end
    
    methods
        function obj = NNS_Scorekeeper()
            %NNS_Scorekeeper Construct an instance of this class
        end
        
        function addPlayer(obj, newPlayer)
            if(isa(newPlayer,'NNS_ScoreboardRow'))
                obj.scoreBoardRows(end+1) = newPlayer;
            elseif(isa(newPlayer,'NNS_PropagatedObject'))
                newRow = NNS_ScoreboardRow(newPlayer);
                obj.scoreBoardRows(end+1) = newRow;
            end
        end

        function removeAllPlayers(obj)
            obj.scoreBoardRows = NNS_ScoreboardRow.empty(1,0);
        end

        function addPointsForPlayer(obj, player, newPoints)
            row = obj.scoreBoardRows(player == [obj.scoreBoardRows.player]);
            row.addToScore(newPoints);
        end
        
        function score = getScoreForPlayer(obj, player)
            row = obj.scoreBoardRows(player == [obj.scoreBoardRows.player]);
            score = row.getScore();
        end
        
        function scores = getScoresForAllRows(obj)
            scores = zeros([length(obj.scoreBoardRows)],2);
            for(i=1:length(obj.scoreBoardRows))
                id = obj.scoreBoardRows(i).player.id;
                score = obj.scoreBoardRows(i).score;
                
                scores(i,:) = [id, score];
            end
        end
        
        function resetScores(obj)
            for(i=1:length(obj.scoreBoardRows)) %#ok<*NO4LP>
                obj.scoreBoardRows(i).score = 0;
            end
        end
        
        function printOutScores(obj)
            fprintf('Player Scores\n--------------------------------\n');
            
            T = table();
            
            for(i=1:length(obj.scoreBoardRows)) %#ok<*NO4LP>
                row = obj.scoreBoardRows(i);
                T(end+1,:) = {row.player.getPlayerName(), row.getScore(), row.player.getPlayerHealth()}; %#ok<AGROW>
            end
            
            T.Properties.VariableNames = {'Player','Score','Health'};
            disp(T);
        end
    end
end

