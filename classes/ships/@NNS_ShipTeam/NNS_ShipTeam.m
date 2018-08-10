classdef NNS_ShipTeam < matlab.mixin.SetGet
    %NNS_ShipTeam Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        None(NaN, '<None>')
        Red(1, 'Red')
        Green(2, 'Green')
        Blue(3, 'Blue')
        Black(4, 'Black')
    end
    
    properties
        id(1,1) double
        str@char
    end
    
    methods
        function obj = NNS_ShipTeam(id, str)
            obj.id = id;
            obj.str = str;
        end
        
        function tf = eq(this, other)
            tf = this.id == other.id;
        end
    end
    
    methods(Static)
        function team = getTeamForStr(str)
            m = enumeration('NNS_ShipTeam');
            
            team = NNS_ShipTeam.empty(0,0);
            for(i=1:length(m)) %#ok<*NO4LP>
                if(strcmpi(m(i).str, str))
                    team = m(i);
                    break;
                end
            end
            
            if(isempty(team))
                error('Could not find ship team for name of: "%s"', str);
            end
        end
        
        function names = getTableListboxStrs()
            [m,~] = enumeration('NNS_ShipTeam');
            names = {m.str}';
        end
    end
end

