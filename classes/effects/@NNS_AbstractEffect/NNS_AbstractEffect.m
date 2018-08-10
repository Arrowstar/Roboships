classdef (Abstract) NNS_AbstractEffect < NNS_PropagatedObject
    %NNS_BasicProjectile Summary of this class goes here
    
    properties
        ownerShip@NNS_PropagatedObject
        relPosToShip@double
        id@double
    end
    
    methods                
        function propagateOneStep(obj, ~)
            shipPos = obj.ownerShip.stateMgr.position;
            obj.stateMgr.position = shipPos + obj.relPosToShip;
        end
                
        function setInactiveAndRemove(obj)
            obj.active = false;           
        end
        
        function drawObjectToAxes(obj, hAxes)
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
                
        function p = getNetPower(obj)
            p = 0;
        end
        
        function cda = getRotCdA(obj)
            cda = 0;
        end
        
        function cda = getLinearCdA(obj)
            cda = 0;
        end
        
        function cda = getRotDragCoeff(obj)
            cda = 0;
        end
          	
        function cda = getLinearDragCoeff(obj)
            cda = 0;
        end
    	
        function sideSurfArea = getSideSurfArea(obj)
            sideSurfArea = 0;
        end
       	
        function fSurfArea = getFrontalSurfArea(obj)
            fSurfArea = 0;
        end
    	
        function momInert = getMomentOfInertia(obj)
            momInert = 1;
        end
        
        function mass = getMass(obj)
            mass = 1;
        end     	
    end
end