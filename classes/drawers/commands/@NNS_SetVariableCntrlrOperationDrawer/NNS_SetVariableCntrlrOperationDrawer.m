classdef NNS_SetVariableCntrlrOperationDrawer < NNS_AbstractControllerCommandDrawer
    %NNS_StartCntrlrOperationDrawer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cmd@NNS_AbstractControllerOperation
    end
    
    methods
        function obj = NNS_SetVariableCntrlrOperationDrawer(cmd)
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
            lhsStr = '<not_set>';
            rhsStr = lhsStr;
            
            if(not(isempty(obj.cmd.var)))
                lhsStr = obj.cmd.var.name;
            end
            
            if(not(isempty(obj.cmd.varSetToValue)))
                rhsStr = obj.cmd.varSetToValue.getValueAsStr();
            end
            
            str = sprintf('%s = %s', lhsStr, rhsStr);
        end
    end
end