classdef NNS_BasicRudder < NNS_AbstractRudder & NNS_AbstractPoweredComponent & NNS_NeuralNetworkCapable
    %NNS_Rudder Provides rotational control of a vessel
    %   Detailed explanation goes here
    
    properties
        ship NNS_PropagatedObject
        rudderShift double = 0.0; % -1.0->1.0
        id double
    end
    
    properties(SetObservable)
       maxTorque double = 10000; %N-m
    end
    
    properties(Constant)
        maximumAllowedMaxTorque = 1E4;
        typeName char = 'Basic Rudder';
    end
    
    methods
        function obj = NNS_BasicRudder(ship, maxTorque)
            %NNS_Rudder Construct an instance of this class
            if(maxTorque > 0)
                obj.maxTorque = maxTorque;
            else
                error('Max torque for a rudder must be greater than 0.  Input was: %f', maxSpeed);
            end
            
            obj.ship = ship;
            obj.id = rand();
        end
               
        function initializeComponent(obj)
            obj.rudderShift = 1.0;
        end
        
        function copiedComp = copy(obj)
            copiedComp = obj.getDefaultBasicRudder();
            copiedComp.maxTorque = obj.maxTorque;
            copiedComp.rudderShift = obj.rudderShift;
        end
        
        function set.rudderShift(obj, newRudderShift)
            if(abs(newRudderShift) > 1.0)
                newRudderShift = sign(newRudderShift) * 1.0;
            end
            
            obj.rudderShift = newRudderShift;
        end
        
        function mass = getMass(obj)
            mass = obj.maxTorque/4;
        end
        
        function curTorque = getCurrentTorque(obj)
            curTorque = obj.maxTorque * obj.rudderShift;
        end
               
        function power = getPowerDrawGen(obj)
            %1000 W = 500 N-m => 2 N-m/W
            power = -2 * obj.maxTorque;
        end
        
        function str = getShortCompName(obj)
            comps = obj.ship.components.getRudderComponents();
            ind = find(comps == obj,1,'first');
            str = sprintf('Rud[%i]',ind);
        end

        function obsInfo = getObservationInfo(obj)
            obsInfo = [];
        end

        function obs = getObservation(obj)
            obs = [];
        end

        function actInfo = getActionInfo(obj)
            actInfo = rlFiniteSetSpec([-1 0 1]);
            actInfo.Name = sprintf('%s: Basic Rudder Shift', obj.getShortCompName());
        end

        function execAction(obj, action, curTime)
            obj.rudderShift = action;
        end
    end
    
    methods(Static)
        function rudder = getDefaultBasicRudder(ship)
            rudder = NNS_BasicRudder(ship,1000);
        end
    end
end

