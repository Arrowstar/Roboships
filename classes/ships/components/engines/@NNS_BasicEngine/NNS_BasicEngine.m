classdef NNS_BasicEngine < NNS_AbstractEngine & NNS_AbstractPoweredComponent & NNS_NeuralNetworkCapable
    %NNS_Engine Provides linear (forward and backwards) thrust to objects
    %it is attached to.
    
    properties
        ship NNS_PropagatedObject
        throttle double = 1.0; %-1.0 -> 1.0   
        id double
    end
    
    properties(SetObservable)
        maxThrust double = 100; %N
    end
    
    properties(Constant)
        maximumAllowedMaxThrust = 1E4;
        typeName char = 'Basic Engine';
    end
    
    methods
        function obj = NNS_BasicEngine(ship, maxThrust)
            %NNS_Engine Construct an instance of this class
            if(maxThrust > 0)
                obj.maxThrust = maxThrust;
            else
                error('Max thrust for an engine must be greater than 0.  Input was: %f', maxThrust);
            end
            
            obj.ship = ship;
            obj.id = rand();
        end
        
        function initializeComponent(obj)
            obj.throttle = 1.0;
        end
        
        function copiedComp = copy(obj)
            copiedComp = obj.getDefaultBasicEngine();
            copiedComp.maxThrust = obj.maxThrust;
            copiedComp.throttle = obj.throttle;
        end
        
        function set.throttle(obj, newThrottle)
            if(abs(newThrottle) > 1.0)
                newThrottle = sign(newThrottle) * 1.0;
            end
            
            obj.throttle = newThrottle;
        end
        
        function mass = getMass(obj)
            mass = obj.maxThrust/4;
        end
        
        function curSpeed = getCurrentThrust(obj)
            curSpeed = obj.maxThrust * obj.throttle;
        end
        
        function power = getPowerDrawGen(obj)
            %1000 W = 500 N => 2 N/W
            power = -2 * obj.maxThrust;
        end
        
        function str = getShortCompName(obj)
            comps = obj.ship.components.getEngineComponents();
            ind = find(comps == obj,1,'first');
            str = sprintf('Eng[%i]',ind);
        end

        function obsInfo = getObservationInfo(obj)
            obsInfo = [];
        end

        function obs = getObservation(obj)
            obs = [];
        end

        function actInfo = getActionInfo(obj)
            actInfo = rlFiniteSetSpec([0 1]);
            actInfo.Name = sprintf('%s: Basic Engine Throttle', obj.getShortCompName());
        end

        function execAction(obj, action, curTime)
            obj.throttle = action;
        end
    end
    
    methods(Static)
        function engine = getDefaultBasicEngine(ship)
            engine = NNS_BasicEngine(ship, 3E2);
        end
    end
end

