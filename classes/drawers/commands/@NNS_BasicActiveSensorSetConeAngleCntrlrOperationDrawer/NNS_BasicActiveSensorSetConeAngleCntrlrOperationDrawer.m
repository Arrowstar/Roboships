classdef NNS_BasicActiveSensorSetConeAngleCntrlrOperationDrawer < NNS_AbstractControllerCommandDrawer
    %NNS_StartCntrlrOperationDrawer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cmd NNS_AbstractControllerOperation
    end
    
    methods
        function obj = NNS_BasicActiveSensorSetConeAngleCntrlrOperationDrawer(cmd)
            obj.cmd = cmd;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            drawObjectOnAxes@NNS_AbstractControllerCommandDrawer(obj, hAxes);
        end
        
        function destroyGraphics(obj)
            destroyGraphics@NNS_AbstractControllerCommandDrawer(obj);
        end
        
        function str = getTitleTextStr(obj)
            str = sprintf('%s: %s', obj.cmd.sensor.getShortCompName(), obj.cmd.cmdTitle); 
        end
        
        function str = getInfoTextStr(obj)
            str = sprintf('%s deg',obj.cmd.desiredConeAngle.getValueAsStr());
        end
    end
end