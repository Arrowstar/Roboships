classdef NNS_SimulationDriver < matlab.mixin.SetGet
    %NSS_SimulationDriver Drives each time step of the simulation
    
    properties
        propObjs NNS_PropagatedObjectList
        clock NNS_SimClock
        showGraphics logical = true;

        fieldAxes matlab.graphics.axis.Axes
        arena NNS_Arena
        shipPlacement 
    end
    
    properties(Dependent = true)
        startTime   %seconds
        endTime     %seconds
        curSimTime  %seconds
        timeStep    %seconds
    end
    
    methods
        function obj = NNS_SimulationDriver(arena,shipPlacement,showGraphics)
            %NSS_SimulationDriver Construct an instance of this class
            arguments
                arena NNS_Arena
                shipPlacement(1,1) NNS_CircularShipPlacement = NNS_CircularShipPlacement();
                showGraphics(1,1) logical = true;
            end

            obj.propObjs = arena.propObjs;
            obj.arena = arena;
            obj.shipPlacement = shipPlacement;
            obj.showGraphics = showGraphics;

            if(obj.showGraphics)
                obj.fieldAxes = arena.getFigAxes();
            end
            
            obj.clock = NNS_SimClock(0, 180, 0, 1/10);
            obj.arena.simClock = obj.clock;
        end
        
        function val = get.startTime(obj)
            val = obj.clock.startTime;
        end
        
        function val = get.endTime(obj)
            val = obj.clock.endTime;
        end
        
        function val = get.curSimTime(obj)
            val = obj.clock.curSimTime;
        end
        
        function val = get.timeStep(obj)
            val = obj.clock.timeStep;
        end
        
        function set.startTime(obj,newVal)
            obj.clock.startTime = newVal;
        end
        
        function set.endTime(obj,newVal)
            obj.clock.endTime = newVal;
        end
        
        function set.curSimTime(obj,newVal)
            obj.clock.curSimTime = newVal;
        end
        
        function set.timeStep(obj,newVal)
            obj.clock.timeStep = newVal;
        end
               
        %drive the simulation by propagating through all time steps
        %TODO: Need alternative exit criteria besides just "hit maximum
        %time step."  No more active vehicles, or something like that.
        %Keep max time as a fail safe though!
        function driveSimulation(obj)
            obj.curSimTime = obj.startTime;

            obj.arena.scorekeeper.removeAllPlayers();
            
            ships = NNS_Ship.empty(1,0);
            for(i=obj.propObjs.getLength():-1:1)
                propObj = obj.propObjs.getObj(i);

                if(isa(propObj,'NNS_AbstractProjectile'))
                    obj.propObjs.removePropObj(propObj);
                else
                    propObj.inializePropObj();
                end

                if(isa(propObj,'NNS_Ship'))
                    obj.arena.scorekeeper.addPlayer(propObj);
                    propObj.clearMassCache();
                    ships(end+1) = propObj; %#ok<AGROW> 
                end
            end

            if(height(obj.arena.scorekeeper.getScoresForAllRows()) == 0)
                for(i=1:length(ships))
                    obj.arena.scorekeeper.addPlayer(ships(i));
                end
            end

            obj.shipPlacement.setInitialShipLocation(ships, obj.arena);
            
            delete(timerfindall());
            drawTimer = timer('TimerFcn',@(x,y) obj.updateGraphics(), 'BusyMode','drop', ...
                              'ExecutionMode','fixedRate', 'Period',1/15);
            t = tic;
            while(obj.curSimTime <= obj.endTime && obj.propObjs.getNumActivePropObjs() > 0)
                t1 = tic;
                obj.curSimTime = obj.curSimTime + obj.timeStep;
                                
                propObjsIndsToBeDeleted = [];
                for(i=1:obj.propObjs.getLength())
                    propObj = obj.propObjs.getObj(i);
                    
                    if(propObj.active == true)
                        propObj.propagateOneStep(obj.timeStep);
                    else
                        propObjsIndsToBeDeleted = horzcat(propObjsIndsToBeDeleted, i); %#ok<AGROW>
                    end
                    
                    if(obj.showGraphics)
                        title(obj.fieldAxes, sprintf('Sim Time = %.3f\nClock Time = %.3f', obj.curSimTime, toc(t)));
                        propObj.drawObjectToAxes(obj.fieldAxes);
                    end
                end
                
                for(j=length(propObjsIndsToBeDeleted):-1:1) %#ok<*NO4LP>
                    obj.propObjs.removePropObj(obj.propObjs.propObjs(propObjsIndsToBeDeleted(j)));
                end
                
                if(obj.propObjs.getNumShipPropObjs() <= 1)
                    break; %if there's only one thing out there or less, end the simulation
                end
                
                if(obj.curSimTime == obj.startTime + obj.timeStep)
                    start(drawTimer);
                end

                %do simulation in "real time"
%                 pause(obj.timeStep - toc(t1));
                
%                 if(obj.showGraphics)
%                     drawnow limitrate;
%                 end

%                 clc;
%                 fprintf('Sim Time = %.3f \nClock Time = %.3f\n', obj.curSimTime, toc(t));
%                 obj.arena.scorekeeper.printOutScores();
            end
            stop(drawTimer);
            
%             fprintf('Sim Time = %.3f\nClock Time = %.3f', obj.curSimTime, toc(t));
        end
        
        function updateGraphics(obj)
            if(obj.showGraphics)
                drawnow limitrate;
            end
        end
    end    
end


