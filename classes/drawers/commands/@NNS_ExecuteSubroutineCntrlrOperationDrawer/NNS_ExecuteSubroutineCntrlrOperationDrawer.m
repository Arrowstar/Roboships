classdef NNS_ExecuteSubroutineCntrlrOperationDrawer < NNS_AbstractControllerCommandDrawer
    %NNS_StartCntrlrOperationDrawer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cmd@NNS_AbstractControllerOperation
    end
    
    methods
        function obj = NNS_ExecuteSubroutineCntrlrOperationDrawer(cmd)
            obj.cmd = cmd;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            drawObjectOnAxes@NNS_AbstractControllerCommandDrawer(obj, hAxes);
        end
        
        function destroyGraphics(obj)
            destroyGraphics@NNS_AbstractControllerCommandDrawer(obj);
        end
        
        function str = getTitleTextStr(obj)
            str = obj.cmd.cmdTitle;
        end
        
        function str = getInfoTextStr(obj)
            str = sprintf('%s',obj.cmd.subroutine.name);
        end
    end
end