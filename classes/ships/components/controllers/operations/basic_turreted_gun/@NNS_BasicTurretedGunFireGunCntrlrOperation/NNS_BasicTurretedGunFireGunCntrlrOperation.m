classdef NNS_BasicTurretedGunFireGunCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gun@NNS_AbstractGun
        
        cmdTitle@char = 'Fire Weapon'
        drawer@NNS_AbstractControllerCommandDrawer
    end
    
    methods
        function obj = NNS_BasicTurretedGunFireGunCntrlrOperation(gun)
            obj.gun = gun;
            obj.drawer = NNS_BasicTurretedGunFireGunCntrlrOperationDrawer(obj);
        end
        
        function executeOperation(obj)
            obj.gun.fireGun(obj.gun.ship.arena.simClock.curSimTime);
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
            str = 'Fire Weapon';
        end
    end
end