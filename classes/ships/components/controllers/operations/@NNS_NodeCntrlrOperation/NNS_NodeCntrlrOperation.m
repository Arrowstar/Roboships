classdef NNS_NodeCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cmdTitle char = 'Node'
        drawer NNS_NodeCntrlrOperationDrawer
    end
    
    methods
        function obj = NNS_NodeCntrlrOperation(~)
            obj.drawer = NNS_NodeCntrlrOperationDrawer(obj);
        end
        
        function executeOperation(obj) %#ok<MANU>
            %nothing
        end
        
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = false;
        end
        
        function setNumeric(obj, numeric)
            %nothing
        end
        
        function comp = getComponent(obj)
            comp = NNS_VehicleComponent.empty(0,0);
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = '[Node]';
        end
    end
end