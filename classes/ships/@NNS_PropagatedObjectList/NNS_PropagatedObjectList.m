classdef NNS_PropagatedObjectList < matlab.mixin.SetGet 
    %NNS_PropagatedObjectList Summary of this class goes here
    
    properties
        propObjs@NNS_PropagatedObject
        
        shootPropObjs = NNS_PropagatedObject.empty(0,0);
        
        id@double
    end
    
    methods
        function obj = NNS_PropagatedObjectList()
            %NNS_PropagatedObjectList Construct an instance of this class
            obj.propObjs = NNS_PropagatedObject.empty(0,0);
            obj.id = rand();
        end
                
        function propObj = getObj(obj,i)
            propObj = obj.propObjs(i);
        end
        
        function lengthObj = getLength(obj)
            lengthObj = length(obj.propObjs);
        end
        
        function addPropagatedObject(obj, propObj)
            obj.propObjs(end+1) = propObj;
            
            if(isa(propObj,'NNS_ShootableObject'))
                obj.shootPropObjs(end+1) = propObj;
            end
        end
        
        function removePropObj(obj, propObj)
            if(isa(propObj,'NNS_AbstractShootablePropagatedObject'))
                obj.shootPropObjs(obj.shootPropObjs == propObj) = [];
            end
            
            obj.propObjs(obj.propObjs == propObj) = [];
            propObj.destroyGraphics();
        end
        
        function removeAllPropObjs(obj)
            obj.propObjs = NNS_PropagatedObject.empty(0,0);
            obj.shootPropObjs = NNS_PropagatedObject.empty(0,0);
        end
        
        function numActive = getNumActivePropObjs(obj)
            numActive = sum([obj.propObjs.active]);
        end
        
        function removeAndReAddAllShips(obj)
            for(i=length(obj.propObjs):-1:1)  
                propObj = obj.propObjs(i);
                obj.removePropObj(propObj);
                
                if(isa(propObj,'NNS_Ship'))
                    obj.addPropagatedObject(propObj);
                end
            end
        end
        
        function shootPropObjs = getShootablePropObjects(obj)
            if(~isempty(obj.shootPropObjs))
                shootPropObjs = obj.shootPropObjs;
            else
                shootPropObjs = NNS_PropagatedObject.empty(0,0);

                activePropObjs = obj.propObjs([obj.propObjs.active] == true);

                for(i=1:length(activePropObjs)) %#ok<*NO4LP>
                    propObj = activePropObjs(i);

                    if(isa(propObj,'NNS_AbstractShootablePropagatedObject') && propObj.active==true)
                        shootPropObjs(end+1) = propObj; %#ok<AGROW>
                    end
                end
                
                obj.shootPropObjs = shootPropObjs;
            end
        end
    end
end

