classdef NNS_BasicTurretedGunBearingControllerParameter < NNS_ControllerComponentParameter
    %NNS_BasicActiveSensorBearingControllerParameter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gun@NNS_AbstractGun
        paramName@char = 'Weapon Bearing';
    end
    
    methods
        function obj = NNS_BasicTurretedGunBearingControllerParameter(gun)
            obj.gun = gun;
        end
        
        function value = getValue(obj)
            value = rad2deg(obj.gun.pointingBearing);
        end
        
        function str = getValueAsStr(obj)
            str = sprintf('%s: %s', obj.gun.getShortCompName(), '[Weapon_Bearing]'); 
        end
        
        function comp = getComponent(obj)
            comp = obj.gun;
        end
    end
    
    methods(Static)
        function str = getListboxStr()
            str = 'Get Weapon Bearing';
        end
    end
end