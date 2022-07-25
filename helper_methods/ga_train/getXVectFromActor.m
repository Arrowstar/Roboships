function x = getXVectFromActor(agent)
    learnParams = agent.getLearnableParameters();
    actorLPs = learnParams.Actor();

    x = [];
    for(i=1:length(actorLPs)) %#ok<*NO4LP> 
        temp = actorLPs{i};
        x = vertcat(x, temp(:)); %#ok<AGROW> 
    end
end