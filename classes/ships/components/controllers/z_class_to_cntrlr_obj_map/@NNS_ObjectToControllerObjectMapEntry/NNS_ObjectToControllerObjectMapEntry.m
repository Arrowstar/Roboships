classdef NNS_ObjectToControllerObjectMapEntry < matlab.mixin.SetGet
    %NNS_ObjectToControllerObjectMap Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        compClassName@char
        cmdClassName@char
        
        type@NNS_ObjectToControllerObjectMapEntryTypeEnum
        
        listboxStr@char
    end
    
    methods
        function obj = NNS_ObjectToControllerObjectMapEntry(compClassName, cmdClassName, type)
            obj.compClassName = compClassName;
            obj.cmdClassName = cmdClassName;
            obj.type = type;
            obj.listboxStr = eval(sprintf('%s.getListboxStr()',obj.cmdClassName));
        end
    end
end