classdef NNS_StartCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cmdTitle char = 'Start'
        drawer NNS_AbstractControllerCommandDrawer
    end
    
    methods
        function obj = NNS_StartCntrlrOperation()
            obj.drawer = NNS_StartCntrlrOperationDrawer(obj);
            obj.isDeletable = false;
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
    end
end