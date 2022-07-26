clc; clear variables; format long g; close all force;

%Include matlabrc, hopefully
%#function matlabrc

warning('off', 'MATLAB:polyshape:repairedBySimplify');
warning('off', 'MATLAB:structOnObject');
warning('off', 'MATLAB:timer:miliSecPrecNotAllowed');
pctRunOnAll warning('off', 'MATLAB:timer:miliSecPrecNotAllowed');

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

load('nn_ship.mat');
ship.arena = arena;

propObjs = NNS_PropagatedObjectList();
arena.propObjs.addPropagatedObject(ship);
arena.propObjs.addPropagatedObject(NNS_Ship.createDefaultBasicShip(arena));

simDriver = NNS_SimulationDriver(arena,false);

%% Run GA to train agent
fun = @(x) gaObjFunc(x, simDriver, ship);

controllers = ship.components.getControllerComps();
agent = controllers(1).getAgent();
x = getXVectFromActor(agent);

options = optimoptions("ga", "PopulationSize",12, "UseParallel",true, "Display","iter", "PlotFcn",{'gaplotscorediversity', 'gaplotbestf', 'gaplotdistance'}, 'MaxGenerations',2000, "FunctionTolerance",0);
[x,fval,exitflag,output,population,scores] = ga(fun,numel(x),[],[],[],[],[],[],[],options);

setXVectFromActor(agent, x);
save('nn_ship_solved.mat','ship');

%% Helper Method
function f = gaObjFunc(x, simDriver, nnShip)
    arguments
        x double
        simDriver NNS_SimulationDriver
        nnShip NNS_Ship
    end

    numRuns = 2;
    f = NaN(1,numRuns);
    for(i=1:numRuns) %#ok<*NO4LP> 
        %get the RL agent we're training and set its learnable values
        controllers = nnShip.components.getControllerComps();
        agent = controllers(1).getAgent();
        setXVectFromActor(agent, x);
    
        %drive simulation
        simDriver.driveSimulation();
    
        %retrieve score
        f(i) = -simDriver.arena.scorekeeper.getScoreForPlayer(nnShip);
    end

    f = mean(f);
end