clc; clear variables; format long g; close all force;

%Include matlabrc, hopefully
%#function matlabrc

warning('off', 'MATLAB:polyshape:repairedBySimplify');
warning('off', 'MATLAB:structOnObject');
warning('off', 'MATLAB:timer:miliSecPrecNotAllowed');
if(not(isempty(gcp('nocreate'))))
    pctRunOnAll warning('off', 'MATLAB:timer:miliSecPrecNotAllowed');
end

%% set pathes if not deployed
if(~isdeployed) 
    restoredefaultpath();
    addpath(genpath('classes'));
    addpath(genpath('helper_methods'));
    addpath(genpath('ships'));
    addpath(genpath('ui'));
end

%% remove any previously running timers
delete(timerfindall); 

%% start main UI
% mainGUI_App();

%% Train Neural Network Ship
arena = NNS_Arena([-50,50], [-50,50]);
% propObjs = NNS_PropagatedObjectList();

numShips = 2;
for(i=1:2)
    load('nn_ship.mat');
    ships(i) = ship; %#ok<SAGROW> 

    ship.arena = arena;
    
    arena.propObjs.addPropagatedObject(ship);
end
% arena.propObjs.addPropagatedObject(NNS_Ship.createDefaultBasicShip(arena));

simDriver = NNS_SimulationDriver(arena,true);

%% Run GA to train agent
fun = @(x) gaObjFunc(x, simDriver, ships);
outputFunc = @(options,state,flag) gaOutputFunc(options,state,flag, ships);

controllers = ships(1).components.getControllerComps();
agent = controllers(1).getAgent();
x = getXVectFromActor(agent);

options = optimoptions("ga", "PopulationSize",4, "UseParallel",false, "OutputFcn",outputFunc, "Display","iter", "PlotFcn",{'gaplotscorediversity', 'gaplotbestf', 'gaplotdistance'}, 'MaxGenerations',2000, "FunctionTolerance",0, "FitnessScalingFcn","fitscalingprop", "CrossoverFcn","crossoverheuristic");
[x,fval,exitflag,output,population,scores] = ga(fun,numel(x),[],[],[],[],[],[],[],options);

setXVectFromActor(agent, x);
ship = ships(1);
save('nn_ship_solved.mat','ship');

% profile off; profile('on', '-historysize',500000000);
% fun(x);
% profile viewer;

%% Helper Method
function f = gaObjFunc(x, simDriver, nnShips)
    arguments
        x double
        simDriver NNS_SimulationDriver
        nnShips NNS_Ship
    end

    numRuns = 1;
    f = NaN(1,numRuns);
    for(i=1:numRuns) %#ok<*NO4LP> 
        %get the RL agent we're training and set its learnable values
        for(j=1:numel(nnShips))
            controllers = nnShips(j).components.getControllerComps();
            agent = controllers(1).getAgent();
            setXVectFromActor(agent, x);
        end
    
        %drive simulation
        simDriver.driveSimulation();
    
        %retrieve score
        f(i) = -mean(simDriver.arena.scorekeeper.getScoresForAllRows());
    end

    f = mean(f);
end

function [state,options,optchanged] = gaOutputFunc(options,state,flag, nnShip)
    if(strcmpi(flag,'iter'))
        genNum = state.Generation;

        scores = state.Score;
        [bestScore,I] = min(scores);
        x = state.Population(I,:);

        controllers = nnShip.components.getControllerComps();
        agent = controllers(1).getAgent();
        setXVectFromActor(agent, x);

        date = datestr(now(), 'YYYYmmDD_HHMMSS');
        filename = sprintf('nnship_Gen_%u_Score_%0.0f_%s.mat', genNum, bestScore, date);
        filepath = fullfile(pwd,'ships','nn_train',filename);

        [folder,~,~] = fileparts(filepath);
        if(not(exist(folder,"dir")))
            mkdir(folder);
        end

        ship = nnShip;
        save(filepath, 'ship');
    end

    optchanged = false;
end