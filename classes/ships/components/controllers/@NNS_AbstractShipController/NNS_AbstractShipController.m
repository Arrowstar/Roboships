classdef(Abstract = true) NNS_AbstractShipController  < NNS_AbstractDrawableVehicleComponent
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
       
    properties
        drawer@NNS_AbstractPropagatedObjectDrawer
    end
    
    methods
        function copiedComp = copy(obj)
            copiedComp = [];
            error('Ship controllers cannot be copied!');
        end 
        
        executeNextOperation(obj);
        
        subroutine = getSubroutineForIndex(obj,ind); %If ind = 0, return main, else if ind > 0, then return that subroutine from the list
    end
end