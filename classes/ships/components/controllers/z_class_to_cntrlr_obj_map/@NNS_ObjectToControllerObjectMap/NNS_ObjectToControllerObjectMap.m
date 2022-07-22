classdef NNS_ObjectToControllerObjectMap < matlab.mixin.SetGet
    %NNS_ObjectToControllerObjectMap Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        entries NNS_ObjectToControllerObjectMapEntry
    end
    
    methods
        function obj = NNS_ObjectToControllerObjectMap()
            obj.entries = NNS_ObjectToControllerObjectMapEntry.empty(0,0);
        end
        
        function addEntry(obj, newEntry)
            obj.entries(end+1) = newEntry;
        end
        
        function h = getAllEntriesForCompClass(obj, compClass)
            h = findobj(obj.entries, 'compClassName', compClass);
        end
        
        function h = getAllEntriesForCompClassAndType(obj, compClass, type)
            h = findobj(obj.entries, 'compClassName', compClass, 'type', type);
        end
        
        function [cmd, entry] = getControllerObjForListboxStr(obj, listBoxStr, comp)
            compClass = class(comp);
            entry = findobj(obj.entries, 'compClassName', compClass, 'listboxStr', strip(listBoxStr));
            
            if(not(isempty(entry)))
                cmd = feval(entry.cmdClassName,comp);
            else
                cmd = [];
            end
        end
        
        function lbStr = getListboxStr(obj, compClass, types)            
            lbStr = {};
            
            if(ismember(NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation, types))
                subEntries = obj.getAllEntriesForCompClassAndType(compClass, NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
                lbStr{end+1} = '<html><b>Operations';
                for(i=1:length(subEntries)) %#ok<*NO4LP>
                    lbStr{end+1} = sprintf('  %s', subEntries(i).listboxStr); %#ok<AGROW>
                end
            end
            
            if(ismember(NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition, types))
                subEntries = obj.getAllEntriesForCompClassAndType(compClass, NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
                lbStr{end+1} = '<html><b>Conditions';
                for(i=1:length(subEntries)) %#ok<*NO4LP>
                    lbStr{end+1} = sprintf('  %s', subEntries(i).listboxStr); %#ok<AGROW>
                end
            end
            
            if(ismember(NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter, types))
                subEntries = obj.getAllEntriesForCompClassAndType(compClass, NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
                lbStr{end+1} = '<html><b>Parameter';
                for(i=1:length(subEntries)) %#ok<*NO4LP>
                    lbStr{end+1} = sprintf('  %s', subEntries(i).listboxStr); %#ok<AGROW>
                end
            end
        end
    end
    
    methods(Static)       
        function map = getMap()
            map = NNS_ObjectToControllerObjectMap();
            
            %Ship
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_SetShipHeadingCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_SetShipSpeedCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_SetVariableCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_ExecuteSubroutineCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_NodeCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);            

            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_IsShipChangingSpeedConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_IsShipTurningConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_IsEqualToConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_IsGreaterThanOrEqualToConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_IsLessThanOrEqualToConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_ShipXPositionControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_ShipYPositionControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_ShipHeadingControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);            
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_ShipSpeedControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_ShipHealthControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_ConstantControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_Ship', 'NNS_MathControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
                        
            %Basic Active Sensor
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorQueryCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorSetBearingCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorSetConeAngleCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorSetFilterCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_HasSensorDetectedObjectConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorBearingControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorConeAngleControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorMaxRangeControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorDetObjRangeControllerParam', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicActiveSensor', 'NNS_BasicActiveSensorDetObjBearingControllerParam', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            %Basic Turreted Gun
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicTurretedGun', 'NNS_BasicTurretedGunSetBearingCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicTurretedGun', 'NNS_BasicTurretedGunFireGunCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicTurretedGun', 'NNS_IsWeaponReloadingConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicTurretedGun', 'NNS_BasicTurretedGunBearingControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
            
            %Basic Mine Layer            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicMineLayer', 'NNS_BasicTurretedGunFireGunCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicMineLayer', 'NNS_IsWeaponReloadingConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            %Basic Missile Launcher
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicMissileLauncher', 'NNS_BasicTurretedGunSetBearingCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicMissileLauncher', 'NNS_BasicTurretedGunFireGunCntrlrOperation', NNS_ObjectToControllerObjectMapEntryTypeEnum.Operation);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicMissileLauncher', 'NNS_IsWeaponReloadingConditional', NNS_ObjectToControllerObjectMapEntryTypeEnum.Condition);
            map.addEntry(entry);
            
            entry = NNS_ObjectToControllerObjectMapEntry('NNS_BasicMissileLauncher', 'NNS_BasicTurretedGunBearingControllerParameter', NNS_ObjectToControllerObjectMapEntryTypeEnum.Parameter);
            map.addEntry(entry);
        end
    end
end