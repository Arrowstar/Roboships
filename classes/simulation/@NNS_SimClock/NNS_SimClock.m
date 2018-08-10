classdef NNS_SimClock < matlab.mixin.SetGet
    %NNS_SimClock Summary of this class goes here
    
    properties
        startTime = 0;   %seconds
        endTime = 20;    %seconds
        curSimTime = 0;  %seconds
        timeStep = 1/33; %seconds
    end
    
    methods
        function obj = NNS_SimClock(startTime,endTime,curSimTime,timeStep)
            %NNS_SimClock Construct an instance of this class
            obj.startTime = startTime;
            obj.endTime = endTime;
            obj.curSimTime = curSimTime;
            obj.timeStep = timeStep;
        end
    end
end

