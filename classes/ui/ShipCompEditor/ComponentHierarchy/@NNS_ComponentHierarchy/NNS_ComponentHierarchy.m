classdef NNS_ComponentHierarchy < matlab.mixin.SetGet
    %NNS_ComponentHierarchy Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        components NNS_HierarchyComponent
        categories NNS_HierarchyCategory
    end
    
    methods
        function obj = NNS_ComponentHierarchy()
            %NNS_ComponentHierarchy Construct an instance of this class
            %   Detailed explanation goes here
            obj.components = NNS_HierarchyComponent.empty(0,0);
            obj.categories = NNS_HierarchyCategory.empty(0,0);
        end
        
        function lbStr = getListboxStr(obj)
            cats = obj.categories;
            comps = obj.components;
            
            lbStr = {};
            for(i=1:length(cats)) %#ok<*NO4LP>
                lbStr{end+1} = ['<html><b>', cats(i).name]; %#ok<AGROW>
                for(j=1:length(comps))
                    if(strcmpi(comps(j).category.name,cats(i).name))
                        lbStr{end+1} = ['  ', comps(j).name]; %#ok<AGROW>
                    end
                end
            end
        end

        function nodes = getTreeNodes(obj, tree)
            cats = obj.categories;
            comps = obj.components;

            for(i=1:length(cats))
                cat = cats(i);
                node = uitreenode(tree, 'Text',cat.name);
                nodes(i) = node; %#ok<AGROW> 

                for(j=1:length(comps))
                    comp = comps(j);
                    if(strcmpi(comp.category.name,cat.name))
                        uitreenode(node, 'Text',comp.name);
                    end
                end
            end
        end
    end
    
    methods(Static)
        function cH = getDefaultComponentHierarchy()
            cH = NNS_ComponentHierarchy();
            
            pwrGen = NNS_HierarchyCategory('Power Generators');
            actSen = NNS_HierarchyCategory('Active Sensors');
            weaponsCat = NNS_HierarchyCategory('Weapons');
            controllersCat = NNS_HierarchyCategory('Controllers');
            
            cH.categories(end+1) = pwrGen;
            cH.categories(end+1) = actSen;
            cH.categories(end+1) = weaponsCat;
            cH.categories(end+1) = controllersCat;
            
            cH.components(end+1) = NNS_HierarchyComponent(NNS_BasicShipController.typeName,controllersCat);
            cH.components(end+1) = NNS_HierarchyComponent(NNS_BasicActiveSensor.typeName,actSen);
            cH.components(end+1) = NNS_HierarchyComponent(NNS_BasicTurretedGun.typeName,weaponsCat);
            cH.components(end+1) = NNS_HierarchyComponent(NNS_BasicMineLayer.typeName,weaponsCat);
            cH.components(end+1) = NNS_HierarchyComponent(NNS_BasicMissileLauncher.typeName,weaponsCat);
            cH.components(end+1) = NNS_HierarchyComponent(NNS_BasicPowerGenerator.typeName,pwrGen);
        end
        
        function newComp = getDefaultComponentForTypeName(typeName, ship)
            switch typeName
                case NNS_BasicPowerGenerator.typeName
                    newComp = NNS_BasicPowerGenerator.getDefaultBasicPowerGenerator(ship);
                case NNS_BasicActiveSensor.typeName
                    newComp = NNS_BasicActiveSensor.getDefaultBasicActiveSensor(ship);
                case NNS_BasicTurretedGun.typeName
                    newComp = NNS_BasicTurretedGun.getDefaultBasicTurretedGun(ship);
                case NNS_BasicMineLayer.typeName
                    newComp = NNS_BasicMineLayer.getDefaultBasicMineLayer(ship);
                case NNS_BasicMissileLauncher.typeName
                    newComp = NNS_BasicMissileLauncher.getDefaultBasicMissileLauncher(ship);
                case NNS_BasicShipController.typeName
                    newComp = NNS_BasicShipController.getDefaultBasicController(ship);
                otherwise
                    newComp = [];
            end
            
            if(not(isempty(newComp)))
                newComp.relPos = [0;0];
            end
        end
    end
end