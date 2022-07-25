classdef(Abstract = true) NNS_AbstractShipController < NNS_AbstractDrawableVehicleComponent
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
       
    properties
        drawer NNS_AbstractPropagatedObjectDrawer
    end
    
    methods
        function copiedComp = copy(obj)
            copiedComp = [];
            error('Ship controllers cannot be copied!');
        end 

        function ind = getControllerInd(obj)
            cntrlrComps = obj.ship.components.getControllerComps();
            ind = find(cntrlrComps == obj,1,'first');
        end
        
        function str = getShortCompName(obj)
            ind = obj.getControllerInd();
            str = sprintf('Ctr[%i]',ind);
        end

        tf = usesPidController(obj);
        
        executeNextOperation(obj);
    end
end