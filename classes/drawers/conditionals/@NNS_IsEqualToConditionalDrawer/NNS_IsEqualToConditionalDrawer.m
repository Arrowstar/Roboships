classdef NNS_IsEqualToConditionalDrawer < NNS_AbstractControllerCommandDrawer
    %NNS_StartCntrlrOperationDrawer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cmd@NNS_AbstractControllerOperation
    end
    
    methods
        function obj = NNS_IsEqualToConditionalDrawer(cmd)
            obj.cmd = cmd;
            obj.outputLineColors = {[34,139,34]/255,'r'};
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
            
            if(not(isempty(obj.cmd.lhs)))
                lhsStr = obj.cmd.lhs.getValueAsStr();
            end
            
            if(not(isempty(obj.cmd.rhs)))
                rhsStr = obj.cmd.rhs.getValueAsStr();
            end
            
            str = sprintf('%s == %s', lhsStr, rhsStr);
        end
    end
end