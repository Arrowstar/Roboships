function setXVectFromActor(agent, x)
    learnParams = agent.getLearnableParameters();
    actorLPs = learnParams.Actor();

    ind = 1;
    for(i=1:length(actorLPs))
        p = actorLPs{i};
        s = size(p);
        cnt = numel(p);
        
        subX = x(ind : ind + cnt - 1);
        actorLPs{i} = reshape(subX, s);
    end

    learnParams.Actor = actorLPs;
    agent.setLearnableParameters(learnParams);
end