classdef(Abstract = true) NNS_AbstractSensor < NNS_AbstractDrawableVehicleComponent
    %NNS_AbstractSensor An abstract class for 'sensors', classes that
    %provide the ability for an object to detect other objects.
    
    properties(Abstract = true)
        drawer@NNS_AbstractPropagatedObjectDrawer
    end
    
    methods
        sensorOutput = querySensor(obj);
        
        sensorOutput = getSensorOutput(obj);
        
        drawObjectOnAxes(obj, hAxes);
    end
end