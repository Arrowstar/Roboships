classdef NNS_AbstractPoweredComponent < matlab.mixin.SetGet
    %NNS_AbstractPoweredComponent Summary of this class goes here
    %   Detailed explanation goes here
     
    methods       
        power = getPowerDrawGen(obj) %positive number returned for generated power, negative for used
    end
end

