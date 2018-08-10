classdef(Abstract = true) NNS_AbstractDrawableVehicleComponent < NNS_VehicleComponent
    %NNS_AbstractDrawableVehicleComponent Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Abstract = true)
        ship@NNS_PropagatedObject
        drawer@NNS_AbstractPropagatedObjectDrawer
        relPos@double         % m - relative to the origin of vessel it's mounted on
    end
    
    properties(Dependent)
        charSize
    end
    
    events
        ShipEditorCompNeedsRedraw
    end
    
    methods(Abstract = true)
        drawObjectOnAxes(obj, hAxes);
        
        destroyGraphics(obj);
        
        str = getInfoStrForComponent(obj);
        
        hFig = createCompPropertiesEditorFigure(obj);
        
        charSize = getCharacteristicSizeForComp(obj);
    end
    
    methods
        function charSize = get.charSize(obj)
            charSize = obj.getCharacteristicSizeForComp();
        end
    end
    
    methods
        function pos = getAbsPosition(obj)
            pos = obj.ship.stateMgr.position + obj.ship.stateMgr.getRotMatrixForHeading()*obj.relPos;
        end 
    end
end

