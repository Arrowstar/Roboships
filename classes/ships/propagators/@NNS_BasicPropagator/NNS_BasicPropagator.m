classdef NNS_BasicPropagator < matlab.mixin.SetGet
    %NNS_BasicPropagator Propagates things in a straight line based on 
    
    properties
        stateMgr@NNS_StateManager
        components@NNS_VehicleComponentList
        propObj@NNS_PropagatedObject
        
        speedCntrlr@NNS_PidController
        headingCntrlr@NNS_PidController
        
        numSubsteps@double = 2;
        
        iterator@function_handle = @(odefun,tspan,y0) ode4(odefun,tspan,y0);
    end
    
    methods
        function obj = NNS_BasicPropagator(stateMgr, components, propObj)
            obj.stateMgr = stateMgr;
            obj.components = components;
            obj.propObj = propObj;
            
            obj.speedCntrlr = NNS_PidController(0,0);
            obj.speedCntrlr.Kp=20;
            obj.speedCntrlr.Ki=15;
            obj.speedCntrlr.Kd=0;
            obj.speedCntrlr.highLimit = 1;
            obj.speedCntrlr.lowLimit = -1;
            
            obj.headingCntrlr = NNS_PidController(0,0);
            obj.headingCntrlr.Kp=20;
            obj.headingCntrlr.Ki=15;
            obj.headingCntrlr.Kd=250; %1228
            obj.headingCntrlr.highLimit = 1;
            obj.headingCntrlr.lowLimit = -1;
        end
        
        function propagateOneStep(obj, timeStep, xLims, yLims)           
            %current state
            curPos = obj.stateMgr.position;
            curVel = obj.stateMgr.velocity;
            curHeading = obj.stateMgr.heading;
            curAngRate = obj.stateMgr.angRate;
            
            %mass / moment of inertia
            mass = obj.propObj.getMass();
            momInert = obj.propObj.getMomentOfInertia();
            
            %drag coeffs
            cdA = obj.propObj.getLinearCdA();
            cdASide = obj.propObj.getRotCdA();
            
            %forces and torques
            thrustMag = obj.getMaximumThrust();
            torqueMag = obj.getMaximumTorque();
            
            %setup and integrate
            obj.speedCntrlr.integral = 0;
            obj.headingCntrlr.integral = 0;
            
            dt = timeStep/obj.numSubsteps;
            tSeg = [0:dt:timeStep]; %#ok<NBRAK>
            
            obj.speedCntrlr.dt = dt;
            obj.headingCntrlr.dt = dt;

            y0 = [curPos(1), curVel(1), curPos(2), curVel(2), curHeading, curAngRate];
            odefun = @(t,y) NNS_BasicPropagator.odefun(t,y, obj.stateMgr, mass, momInert, thrustMag, torqueMag, cdA, cdASide, obj.speedCntrlr, obj.headingCntrlr);
            [y] = obj.iterator(odefun, tSeg, y0);
%             [t,y] = ode45(odefun, tSeg, y0);
            
            %set current Position and Heading
            obj.stateMgr.position = [y(end,1), y(end,3)]';
            obj.stateMgr.velocity = [y(end,2), y(end,4)]';
            obj.stateMgr.heading = y(end,5);
            obj.stateMgr.angRate = y(end,6);
            
            %checks on position
            if(obj.stateMgr.position(1) < min(xLims))
                obj.stateMgr.position(1) = min(xLims);
                obj.stateMgr.velocity(1) = 0;
            elseif(obj.stateMgr.position(1) > max(xLims))
                obj.stateMgr.position(1) = max(xLims);
                obj.stateMgr.velocity(1) = 0;
            end
            if(obj.stateMgr.position(2) < min(yLims))
                obj.stateMgr.position(2) = min(yLims);
                obj.stateMgr.velocity(2) = 0;
            elseif(obj.stateMgr.position(2) > max(yLims))
                obj.stateMgr.position(2) = max(yLims);
                obj.stateMgr.velocity(2) = 0;
            end
        end
        
        function curThrust = getCurrentThrust(obj)
            %get engines
            engComps = obj.components.getEngineComponents();
            
            %compute current speed
            curThrust = 0;
            for(i=1:length(engComps)) %#ok<*NO4LP>
                curThrust = curThrust + engComps(i).getCurrentThrust();
            end 
        end
        
        function maxThrust = getMaximumThrust(obj)
            %get engines
            engComps = obj.components.getEngineComponents();
            
            %compute current speed
            maxThrust = 0;
            for(i=1:length(engComps)) %#ok<*NO4LP>
                maxThrust = maxThrust + engComps(i).maxThrust;
            end 
        end
                
        function thrustVector = getThrustVector(obj)
            curThrust = getCurrentThrust(obj);
            thrustVector = curThrust * obj.stateMgr.getHeadingUnitVector();
        end
        
        function curTorque = getCurrentTorque(obj)
            %get rudders
            rudderComps = obj.components.getRudderComponents();
            
            %compute current speed
            curTorque = 0;
            for(i=1:length(rudderComps)) %#ok<*NO4LP>
                curTorque = curTorque + rudderComps(i).getCurrentTorque();
            end 
        end
        
        function maxTorque = getMaximumTorque(obj)
            %get rudders
            rudderComps = obj.components.getRudderComponents();
            
            %compute current speed
            maxTorque = 0;
            for(i=1:length(rudderComps)) %#ok<*NO4LP>
                maxTorque = maxTorque + rudderComps(i).maxTorque;
            end 
        end
        
        function velVector = getVelVector(obj)
            velVector = obj.stateMgr.velocity;
        end
    end

    methods(Static)
        function dydt = odefun(~,y, stateMgr, mass, momInert, thrustMag, torqueMag, CdA, CdASide, speedCntrlr, headingCntrlr)
            stateMgr.position = [y(1);y(3)];
            stateMgr.velocity = [y(2);y(4)];
            stateMgr.heading = (y(5));
            stateMgr.angRate = y(6);
            
            %Throttles
            inputVel = norm(stateMgr.velocity);
            a = [stateMgr.velocity;0];
            b = [stateMgr.getHeadingUnitVector();0];
            if(abs(dang(a, b)) > pi/2)
                inputVel = -inputVel;
            end
            
            linThrottle = 0;
            if(thrustMag ~= 0)
                linThrottle = speedCntrlr.doPID(inputVel);
            end
            
            headingInput = stateMgr.heading;
            setPoint = headingCntrlr.getPIDParam(headingCntrlr.PID_SETPOINT);
            setPtMin = setPoint - pi;
            setPtMax = setPoint + pi;
            
            if(headingInput < setPtMin)
                while(headingInput < setPtMin)
                    headingInput = headingInput + 2*pi;
                end
            elseif(headingInput > setPtMax)
                while(headingInput > setPtMax)
                    headingInput = headingInput - 2*pi;
                end
            end
            
            angThrottle = 0;
            if(torqueMag ~= 0)
                angThrottle = headingCntrlr.doPID(headingInput);
            end
            
            %thrust
            thrustVector = [0;0];
            if(linThrottle~=0)
                thrustVector = linThrottle * thrustMag * stateMgr.getHeadingUnitVector();
            end
                        
            %drag
            if(CdA == CdASide)
                adjustedCdA = CdA;
            else
                a = [stateMgr.getHeadingUnitVector();0];
                b = [stateMgr.velocity;0];
                sideSlipAng = dang(a, b);
                x1 = 1;
                x2 = 0;
                y1 = CdA;
                y2 = CdASide;

                adjustedCdA = ((y2-y1)/(x1-x2))*(sin(sideSlipAng) - x2) + y1;
            end

            dragMag = (1/2)*997*adjustedCdA*norm(stateMgr.velocity)^2;
            if(dragMag > 0)
                drag = dragMag * normVector(stateMgr.velocity);
            else
                drag = [0;0];
            end
            
            %rotational drag (not technically correct but good enough here
            rotDrag = sign(stateMgr.angRate) * (1/2)*997*CdASide*stateMgr.angRate^2;
            
            %x
            dydt(1) = y(2);
            dydt(2) = (thrustVector(1) - drag(1))/mass; %x thrust and drag
            
            %y
            dydt(3) = y(4);
            dydt(4) = (thrustVector(2) - drag(2))/mass; %y thrust and drag
            
            %angle
            dydt(5) = y(6);
            dydt(6) = (angThrottle * torqueMag - rotDrag)/momInert; %torque
            
            dydt = dydt';
        end
    end
end

