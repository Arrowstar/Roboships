classdef NNS_SensorFilterEnum < matlab.mixin.SetGet
    %NNS_SensorFilterEnum Summary of this class goes here
    %   Detailed explanation goes here

    enumeration
        NoFilter('No Filter', 0, true)
        EnemyShips('Enemy Ships', 1, true)
        AlliedShips('Allied Ships', 2, true)
        AnyShips('Any Ships', 3, true)
        AnyProjectile('Any Weapons', 4, true)
        BasicProjectile('Ballistic Projectiles', 5, true)
        BasicMine('Mines', 6, true)
        BasicMissile('Missiles', 7, true)
        EnemyShipsBasicMissile('EnemyShipsForBasicMissleSensor', -99, false)
    end    

    properties
        name(1,:) char
        id(1,1) double
        showToUser(1,1) logical
    end

    methods
        function obj = NNS_SensorFilterEnum(name, id, showToUser)
            obj.name = name;
            obj.id = id;
            obj.showToUser = showToUser;
        end
    end

    methods(Static)
        function [listBoxStrs, m] = getListBoxStrs()
            [m,~] = enumeration('NNS_SensorFilterEnum');
            
            listBoxStrs = {};
            for(i=1:length(m)) %#ok<*NO4LP>
                listBoxStrs{end+1} = m(i).name; %#ok<AGROW>
            end
        end
    end
end