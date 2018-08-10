classdef NNS_Arena < matlab.mixin.SetGet
    %NNS_Arena Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xLims@double
        yLims@double
        
        propObjs@NNS_PropagatedObjectList
        simClock@NNS_SimClock
    end
    
    methods
        function obj = NNS_Arena(xLims,yLims)
            %NNS_Arena Construct an instance of this class
            %   Detailed explanation goes here
            obj.xLims = xLims;
            obj.yLims = yLims;
            
            obj.propObjs = NNS_PropagatedObjectList();
        end
    end
    
    methods
        function [hAxes,hFig] = getFigAxes(obj)
            hFig = figure('Visible','on');
            hAxes = axes(hFig);
            hAxes.SortMethod = 'childorder';
            xlim(hAxes,obj.xLims);
            ylim(hAxes,obj.yLims);
            hAxes.Color = [173/255,216/255,230/255];
            hAxes.GridColor = 'k';
            hAxes.GridAlpha = 0.8;
            grid on;
        end
    end
end

