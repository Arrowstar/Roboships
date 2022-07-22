classdef NNS_SimulationDriver < matlab.mixin.SetGet
    %NSS_SimulationDriver Drives each time step of the simulation
    
    properties
        propObjs NNS_PropagatedObjectList
        clock NNS_SimClock
        showGraphics logical = true;

        fieldAxes matlab.graphics.axis.Axes
        arena NNS_Arena
    end
    
    properties(Dependent = true)
        startTime   %seconds
        endTime     %seconds
        curSimTime  %seconds
        timeStep    %seconds
    end
    
    methods
        function obj = NNS_SimulationDriver(arena,showGraphics)
            %NSS_SimulationDriver Construct an instance of this class
            obj.propObjs = arena.propObjs;
            obj.arena = arena;
            obj.fieldAxes = arena.getFigAxes();
            obj.showGraphics = showGraphics;
            
            obj.clock = NNS_SimClock(0, 300, 0, 1/15);
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
            
            for(i=obj.propObjs.getLength():-1:1)
                if(isa(obj.propObjs.getObj(i),'NNS_AbstractProjectile'))
                    obj.propObjs.removePropObj(obj.propObjs.getObj(i));
                else
                    obj.propObjs.getObj(i).inializePropObj();
                end
            end
            
            delete(timerfindall());
            drawTimer = timer('TimerFcn',@(x,y) obj.updateGraphics(), 'BusyMode','drop', ...
                              'ExecutionMode','fixedRate', 'Period',1/15);
            t = tic;
            while(obj.curSimTime <= obj.endTime && obj.propObjs.getNumActivePropObjs() > 0)
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
%                         title(obj.fieldAxes, sprintf('Sim Time = %.3f\nClock Time = %.3f', obj.curSimTime, toc(t)));
                        propObj.drawObjectToAxes(obj.fieldAxes);
                    end
                end
                
                for(j=length(propObjsIndsToBeDeleted):-1:1) %#ok<*NO4LP>
                    obj.propObjs.removePropObj(obj.propObjs.propObjs(propObjsIndsToBeDeleted(j)));
                end
                
                if(length(obj.propObjs.propObjs) <= 1)
                    break; %if there's only one thing out there or less, end the simulation
                end
                
                if(obj.curSimTime == obj.startTime + obj.timeStep)
                    start(drawTimer);
                end
                
%                 if(obj.showGraphics)
%                     drawnow limitrate;
%                 end
            end
            stop(drawTimer);
            
            disp(sprintf('Sim Time = %.3f\nClock Time = %.3f', obj.curSimTime, toc(t)));
        end
        
        function updateGraphics(obj)
            if(obj.showGraphics)
                drawnow limitrate;
            end
        end
    end    
end


