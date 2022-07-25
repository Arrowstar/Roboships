classdef NNS_VehicleComponentList < matlab.mixin.SetGet
    %NNS_VehicleComponentList Summary of this class goes here
    
    properties
        components NNS_VehicleComponent
        
        hullComps = NNS_AbstractHull.empty(0,0);
        engComps = NNS_AbstractEngine.empty(0,0);
        rudComps = NNS_AbstractRudder.empty(0,0);
        pwrComps = NNS_AbstractPowerSource.empty(0,0);
        poweredComps = NNS_AbstractPoweredComponent.empty(0,0);
        sensorComps = NNS_AbstractSensor.empty(0,0);
        gunComps = NNS_AbstractGun.empty(0,0);
        ctrlrComps = NNS_AbstractShipController.empty(0,0);
        nnComps

        drawableComps = NNS_AbstractDrawableVehicleComponent.empty(0,0);
    end
    
    methods
        function obj = NNS_VehicleComponentList()
            %NNS_VehicleComponentList Construct an instance of this class
            obj.components = NNS_VehicleComponent.empty(0,0);
        end
        
        function addComponent(obj, comp)
            if(isa(comp,'NNS_VehicleComponent'))
                obj.components(end+1) = comp;
                resetCompCaches(obj, comp);
            else
                error('Tried to add a non-Vehicle Component object to the vehicle component array in NNS_Ship.  Object type: %s', class(comp));
            end
        end
        
        function removeComponent(obj, comp)
            obj.components(obj.components == comp) = [];
            resetCompCaches(obj, comp);
        end
        
        function resetCompCaches(obj, comp)
            if(isa(comp,'NNS_AbstractEngine')) %reset the cache of these component lists
                obj.engComps = NNS_AbstractEngine.empty(0,0);
            elseif(isa(comp,'NNS_AbstractRudder'))
                obj.rudComps = NNS_AbstractRudder.empty(0,0);
            elseif(isa(comp,'NNS_AbstractPowerSource'))
                obj.pwrComps = NNS_AbstractPowerSource.empty(0,0);
            elseif(isa(comp,'NNS_AbstractSensor'))
                obj.sensorComps = NNS_AbstractSensor.empty(0,0);
            elseif(isa(comp,'NNS_AbstractGun'))
                obj.gunComps = NNS_AbstractGun.empty(0,0);
            elseif(isa(comp,'NNS_AbstractHull'))
                obj.hullComps = NNS_AbstractHull.empty(0,0);
            elseif(isa(comp,'NNS_AbstractShipController'))
                obj.ctrlrComps = NNS_AbstractShipController.empty(0,0);
            end

            if(isa(comp,'NNS_AbstractPoweredComponent'))
                obj.poweredComps = NNS_AbstractPoweredComponent.empty(0,0);
            end
            
            if(isa(comp,'NNS_AbstractDrawableVehicleComponent'))
                obj.drawableComps = NNS_AbstractDrawableVehicleComponent.empty(0,0);
            end

            if(isa(comp, 'NNS_NeuralNetworkCapable'))
                obj.nnComps = [];
            end
        end
        
        function sortComponentsByCharSize(obj)
            
        end
        
        function engComps = getEngineComponents(obj)
            if(~isempty(obj.engComps))
                engComps = obj.engComps;
            else
                engComps = NNS_AbstractEngine.empty(0,0);
                for(i=1:length(obj.components)) %#ok<*NO4LP>
                    if(isa(obj.components(i),'NNS_AbstractEngine'))
                        engComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.engComps = engComps;
            end
        end
        
        function rudComps = getRudderComponents(obj)
            if(~isempty(obj.rudComps))
                rudComps = obj.rudComps;
            else
                rudComps = NNS_AbstractRudder.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_AbstractRudder'))
                        rudComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.rudComps = rudComps;
            end
        end
        
        function pwrComps = getPowerSrcComponents(obj)
            if(~isempty(obj.pwrComps))
                pwrComps = obj.pwrComps;
            else
                pwrComps = NNS_AbstractPowerSource.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_AbstractPowerSource'))
                        pwrComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.pwrComps = pwrComps;
            end
        end
        
        function poweredComps = getPoweredComponents(obj)
            if(~isempty(obj.poweredComps))
                poweredComps = obj.poweredComps;
            else
                poweredComps = NNS_VehicleComponent.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_AbstractPoweredComponent'))
                        poweredComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.poweredComps = poweredComps;
            end
        end
        
        function sensorComps = getSensorComponents(obj)
            if(~isempty(obj.sensorComps))
                sensorComps = obj.sensorComps;
            else
                sensorComps = NNS_AbstractSensor.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_AbstractSensor'))
                        sensorComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.sensorComps = sensorComps;
            end
        end
        
        function gunComps = getGunComponents(obj)
            if(~isempty(obj.gunComps))
                gunComps = obj.gunComps;
            else
                gunComps = NNS_AbstractGun.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_AbstractGun'))
                        gunComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.gunComps = gunComps;
            end
        end
        
        function hullComps = getHullComponents(obj)
            if(~isempty(obj.hullComps))
                hullComps = obj.hullComps;
            else
                hullComps = NNS_AbstractHull.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_AbstractHull'))
                        hullComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.hullComps = hullComps;
            end
        end
        
        function ctrlrComps = getControllerComps(obj)
            if(~isempty(obj.ctrlrComps))
                ctrlrComps = obj.ctrlrComps;
            else
                ctrlrComps = NNS_AbstractShipController.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_AbstractShipController'))
                        ctrlrComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.ctrlrComps = ctrlrComps;
            end
        end

        function drawableComps = getDrawableComponents(obj)
            if(~isempty(obj.drawableComps))
                drawableComps = obj.drawableComps;
            else
                drawableComps = NNS_AbstractDrawableVehicleComponent.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_AbstractDrawableVehicleComponent'))
                        drawableComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                [~,I] = sort([drawableComps.charSize],'descend');
                obj.drawableComps = drawableComps(I);
                drawableComps = obj.drawableComps;
            end
        end

        function nnComps = getNeuralNetworkCapableComponents(obj)
            if(~isempty(obj.nnComps))
                nnComps = obj.nnComps;
            else
                nnComps = NNS_VehicleComponent.empty(0,0);
                for(i=1:length(obj.components))
                    if(isa(obj.components(i),'NNS_NeuralNetworkCapable'))
                        nnComps(end+1) = obj.components(i); %#ok<AGROW>
                    end
                end
                
                obj.nnComps = nnComps;
            end
        end
    end
end