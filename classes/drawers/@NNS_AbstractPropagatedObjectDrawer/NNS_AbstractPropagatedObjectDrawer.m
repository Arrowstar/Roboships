classdef NNS_AbstractPropagatedObjectDrawer < matlab.mixin.SetGet
    %NNS_AbstractPropagatedObjectDrawer An abstract class for drawing
    %propagated objects on a figure axes.
    
    properties
    end
    
    methods
        drawObjectOnAxes(obj, hAxes)
        
        patch = getPatchForDrawnComponents(obj);
        
        destroyGraphics(obj);
    end
end

