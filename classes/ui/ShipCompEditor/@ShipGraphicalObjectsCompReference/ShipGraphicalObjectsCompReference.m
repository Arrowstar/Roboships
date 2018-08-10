classdef ShipGraphicalObjectsCompReference < matlab.mixin.SetGet 
    %ShipGraphicalObjectsCompReference Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cPoly
        comp@NNS_VehicleComponent
    end
    
    methods
        function obj = ShipGraphicalObjectsCompReference(cPoly,comp)
            %ShipGraphicalObjectsCompReference Construct an instance of this class
            %   Detailed explanation goes here
            obj.cPoly = cPoly;
            obj.comp = comp;
        end
    end
end

