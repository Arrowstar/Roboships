classdef NNS_IsWeaponReloadingConditional < NNS_AbstractControllerConditional
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
       
    properties        
        gun NNS_AbstractGun
        
        cmdTitle char = 'Is Reloading?';
        drawer NNS_IsWeaponReloadingConditionalDrawer
        
        condAns logical = false
    end
    
    methods
        function obj = NNS_IsWeaponReloadingConditional(gun)
            obj.gun = gun;
            obj.drawer = NNS_IsWeaponReloadingConditionalDrawer(obj);
            obj.numOutputs = 2;
            
            for(i=1:obj.numOutputs) %#ok<*NO4LP>
                obj.nextOp{i} = NNS_AbstractControllerOperation.empty(0,0);
            end
        end
        
        function executeOperation(obj)
            obj.condAns = obj.gun.isGunLoaded(obj.gun.ship.arena.simClock.curSimTime);
        end
        
        function nextOp = getNextOperation(obj)
            if(obj.condAns == true)
                nextOp = obj.getNextOperationForInd(1);
            else
                nextOp = obj.getNextOperationForInd(2);
            end
        end
               
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function setNumeric(obj, numeric)
            %nothing
        end
        
        function comp = getComponent(obj)
            comp = obj.gun;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Is Reloading';
        end
    end
end