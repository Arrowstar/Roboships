classdef NNS_BasicTurretedGunSetBearingCntrlrOperation < NNS_AbstractControllerOperation
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gun@NNS_AbstractGun
        
        desiredBearing@NNS_ControllerNumeric; %rad
        
        cmdTitle@char = 'Set Bearing';
        drawer@NNS_AbstractControllerCommandDrawer
    end
    
    methods
        function obj = NNS_BasicTurretedGunSetBearingCntrlrOperation(gun)
            obj.gun = gun;
            obj.drawer = NNS_BasicTurretedGunSetBearingCntrlrOperationDrawer(obj);
            obj.desiredBearing = NNS_ControllerConstant(0);
        end
        
        function executeOperation(obj)
            obj.gun.pointingBearing = deg2rad(obj.desiredBearing.getValue());
        end
        
        function tf = requiresTimeStep(obj) %#ok<MANU>
            tf = true;
        end
        
        function numerics = getNumeric(obj)
            numerics = obj.desiredBearing;
        end
        
        function setNumeric(obj, numeric)
            obj.desiredBearing = numeric;
        end
        
        function comp = getComponent(obj)
            comp = obj.gun;
        end
        
        function set.desiredBearing(obj,newBearing)
            if(isa(newBearing,'double'))
                newBearing = NNS_ControllerConstant(newBearing);
            end
            obj.desiredBearing = newBearing;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Set Bearing';
        end
    end
end