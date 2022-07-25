classdef NNS_ControllerSubroutine  < matlab.mixin.SetGet
    %NNS_ControllerSubroutine Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name char = 'Untitled Subroutine';
        
        operations NNS_AbstractControllerOperation
        opNext NNS_AbstractControllerOperation
    end
    
    methods
        function obj = NNS_ControllerSubroutine(name)
            obj.name = name;
        end
        
        function initializeComponent(obj)
            obj.opNext = obj.operations(1);
        end
        
        function executeNextOp(obj)
            runLoop = true;
            
            while(runLoop == true)
                if(isempty(obj.opNext))
                    obj.initializeComponent();
                    break;
                end
                obj.opNext.executeOperation();
                runLoop = not(obj.opNext.requiresTimeStep);
                
                obj.opNext = obj.opNext.getNextOperation();
            end
        end
        
        function addOperation(obj, newOp)
            obj.operations(end+1) = newOp;
            
            if(length(obj.operations) == 1)
                obj.opNext = newOp;
            end
        end
        
        function removeOperation(obj, op)
%             obj.operations(obj.operations == op) = [];
            
            for(i=1:length(obj.operations)) %#ok<NO4LP>
                if(obj.operations(i) == op)
                    obj.operations(i) = [];
                    break;
                end
            end
        end
    end
    
    methods(Static)
        function sr = getDefaultSubroutine(ship)
            sr = NNS_ControllerSubroutine('Untitled Subroutine');
            
            startOp = NNS_StartCntrlrOperation();
            sr.addOperation(startOp);
            
%             setSpeedOp = NNS_SetShipSpeedCntrlrOperation(ship);
%             setSpeedOp.desiredSpeed = NNS_ControllerConstant(999);
%             sr.addOperation(setSpeedOp);
%             startOp.setNextOperation(setSpeedOp);
%             
%             setHeadingOp = NNS_SetShipHeadingCntrlrOperation(ship);
%             setHeadingOp.desiredHeading = NNS_ControllerConstant(deg2rad(45));
%             sr.addOperation(setHeadingOp);
%             setSpeedOp.setNextOperation(setHeadingOp);
%             
%             sensor = ship.components.getSensorComponents();
%             sensor = sensor(1);
%             setSensorBearingOp = NNS_BasicActiveSensorSetBearingCntrlrOperation(sensor);
%             setSensorBearingOp.desiredBearing = NNS_ShipXPositionControllerParameter(ship);
%             sr.addOperation(setSensorBearingOp);
%             setHeadingOp.setNextOperation(setSensorBearingOp);
%             
%             setConeAngleOp = NNS_BasicActiveSensorSetConeAngleCntrlrOperation(sensor);
%             setConeAngleOp.desiredConeAngle = NNS_ControllerConstant(deg2rad(1));
%             sr.addOperation(setConeAngleOp);
%             setSensorBearingOp.setNextOperation(setConeAngleOp);
%             
%             gun = ship.components.getGunComponents();
%             gun = gun(1);
%             setGunBearingOp = NNS_BasicTurretedGunSetBearingCntrlrOperation(gun);
%             setGunBearingOp.desiredBearing = NNS_BasicActiveSensorBearingControllerParameter(sensor);
%             sr.addOperation(setGunBearingOp);
%             setConeAngleOp.setNextOperation(setGunBearingOp);
%             
%             querySensorOp = NNS_BasicActiveSensorQueryCntrlrOperation(sensor);
%             sr.addOperation(querySensorOp);
%             setGunBearingOp.setNextOperation(querySensorOp);
%             
%             fireGunOp = NNS_BasicTurretedGunFireGunCntrlrOperation(gun);
%             sr.addOperation(fireGunOp);
%             querySensorOp.setNextOperation(fireGunOp);
%             fireGunOp.setNextOperation(setSensorBearingOp);
        end
    end
end

