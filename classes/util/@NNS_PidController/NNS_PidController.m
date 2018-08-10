classdef NNS_PidController < matlab.mixin.SetGet
    % /**
    %  *  Proportional <tt>&lt;P&gt;</tt>, Integral <tt>&lt;I&gt;</tt>, Derivative <tt>&lt;D&gt;</tt> controller implementation.
    %  *
    %  *  <code>P</code> depends on the present error, <code>I</code> on the accumulation of past errors, and <code>D</code> is a
    %  *  prediction of future errors, based on
    %  *  current rate of change.
    %  * <p> <b>Proportional gain, Kp:</b>
    %  * Larger values typically mean faster response since the larger the error, the larger the proportional term compensation.
    %  * An excessively large proportional gain will lead to process instability and oscillation.<br>
    %  * <p><b>Integral gain, Ki:</b>
    %  * Larger values imply steady state errors are eliminated more quickly. The trade-off is larger overshoot: any negative error integrated during transient response must be integrated away by positive error before reaching steady state.
    %  * <p><b>Derivative gain, Kd:</b>
    %  * Larger values decrease overshoot, but slow down transient response and may lead to instability due to signal noise amplification in the differentiation of the error.
    %  *  <p><b>Definitions:</b>
    %  *  <ul>
    %  *  <li>MV - Manipulated Variable. What the PID controller calculates to be used as the input to the process (i.e. motor speed).
    %  *  <LI>PV - Process Variable. The measurement of the process value.
    %  *  <LI>SP - Setpoint. The desired value that the PID controller works to achieve through process changes by MV.
    %  *  <li>error - The difference between PV and MV.
    %  *  <li>dt - Time delta in milliseconds between calls to <tt>{@link #doPID}</tt>.
    %  *  </ul>
    %  *
    %  *  The proportional term <code>P</code> (sometimes called gain) makes a change to the output that is proportional to the
    %  *  current error value. The proportional response is adjusted by multiplying the error by Kp. A high proportional gain
    %  *  results in a large change in the output for a given change in the error.
    %  *  <P>
    %  *  The integral term <code>I</code> (sometimes called reset) accelerates the movement of the process towards the setpoint and eliminates the residual
    %  *  steady-state error that
    %  *  occurs with a proportional only controller. However, since the integral term is responding to accumulated errors from the past,
    %  *  it can cause the present value to overshoot the setpoint value. The magnitude of the contribution of the integral term to the
    %  *  overall control action is determined by the integral gain, Ki. This implementation uses <code>I += Ki * error * dt</code>.
    %  *  If error is potentially large, using a small Ki gain
    %  *  value may be necessary as the amplitude of <code>I</code> may cause instability.
    %  *  <p>
    %  *  Integral windup is basically what happens when the controller is pushed into a state where it has reached the maximum output
    %  *  power but the set point has not been reached. In this situation the integral term will continue to grow even though it can
    %  *  no longer have any impact on the controller output. The problem is that when the controller finally manages to get to the
    %  *  set point the integral term may have grown very large and this will cause an overshoot that can take a relatively long time
    %  *  to correct (as the integral value now needs to unwind). Two classic examples are:
    %  *  <ul>
    %  * <li>A large change in the set point. This will take time for the motor or whatever to move to that point meanwhile the integral
    %  * term builds up, and eventually will cause an overshoot.
    %  * <li>The motor is stalled for a short period of time, at full power, again the integral term will continue to grow and will
    %  * cause an overshoot.
    %  * </ul>
    %  * This class provides two methods to manage integral windup:
    %  * <ol><li>
    %  * Disabling the integral function until the PV has entered the controllable region
    %  * <li>Preventing the integral term from accumulating above or below pre-determined bounds
    %  * </ol>
    %  *
    %  * The derivative term <code>D</code> (sometimes called rate) slows the rate of change of the controller output and this effect is most noticeable
    %  * close to the controller setpoint. Hence, derivative control is used to reduce the magnitude of the overshoot produced by the
    %  * integral component (<code>I</code>) and improve the combined controller-process stability. The rate of change of the process error is
    %  * calculated by determining the slope of the error over time and multiplying this rate of change by the derivative gain Kd.
    %  * The D term in the controller is highly sensitive to noise in the error term, and can cause a process to become unstable if
    %  * the noise and the derivative gain Kd are sufficiently large.
    %  *  <p>
    %  *  It is important to tune the PID controller with an implementation of a consistent delay between calls to <code>doPID()</code>
    %  *  because the MV calc in a PID controller is time-dependent by definition. This implementation provides an optional delay (set
    %  *  in the constructor) and calculates the time delta (<code>dt</code>) between
    %  *  calls to <code>{@link #doPID}</code> in milliseconds.
    %  *  <p>
    %  *  Reference: Wikipedia- <a href="http://en.wikipedia.org/wiki/PID_controller" target="_blank">http://en.wikipedia.org/wiki/PID_controller</a>
    %  *
    %  *  @author Kirk Thompson, 2/5/2011 &lt;lejos@mosen.net&gt;
    %  */
    properties(Constant)
        PID_KP = 0;
        PID_KI = 1;
        PID_KD = 2;
        PID_RAMP_POWER = 3;
        PID_RAMP_THRESHOLD = 4;
        PID_DEADBAND = 5;
        PID_LIMITHIGH = 6;
        PID_LIMITLOW = 7;
        PID_SETPOINT = 8;
        PID_I_LIMITLOW = 9;
        PID_I_LIMITHIGH = 10;
        PID_I = 11;
        PID_PV = 12;
    end
    
    properties
        Kp=1.0;
        Ki=0.0;
        Kd=0.0;
        highLimit = 0;
        lowLimit = 0;
        previous_error = 0;
        deadband = 0;
        dt = 1;
        cycleTime=0;
        setpoint;
        error;
        integral = 0;
        derivative;
        integralHighLimit = 0;
        integralLowLimit = 0;
        integralLimited = false;
        disableIntegral = false;
        power = 0;
        rampThresold = 0;
        rampExtent = 1;
        msdelay;
        cycleCount=0;
        PV;
    end
    
    methods
        %     /**
        %      * Construct a PID controller instance using passed setpoint (SP) and millisecond delay (used before returning from a call to
        %      * <code>doPID()</code>).
        %      * @param setpoint The goal of the MV
        %      * @param msdelay The delay in milliseconds. Set to 0 to disable any delay.
        %      * @see #doPID
        %      * @see #setDelay
        %      */
        function obj = NNS_PidController(setpoint,msdelay)
            obj.setpoint = setpoint;
            obj.msdelay = msdelay;
        end
        
        %     /**
        %      * Set PID controller parameters.
        %      * @param paramID What parameter to set. See the constant definitions for this class.
        %      * @param value The value to set it to. Note that some values are cast to <tt>int</tt> depending on the particular <tt>paramID</tt> value used.
        %      * @see #getPIDParam
        %      */
        function setPIDParam(obj, paramID, value)
            switch (paramID)
                case NNS_PidController.PID_KP
                    obj.Kp = value;
                case NNS_PidController.PID_KI
                    obj.Ki = value;
                case NNS_PidController.PID_KD
                    obj.Kd = value;
                case NNS_PidController.PID_RAMP_POWER
                    obj.power = value;
                    obj.rampExtent = Math.pow(obj.rampThresold, obj.power);
                case NNS_PidController.PID_RAMP_THRESHOLD
                    obj.rampThresold = value;
                    if (obj.rampThresold==0)
                        %break;
                    else
                        obj.rampExtent = Math.pow(obj.rampThresold, obj.power);
                    end
                case NNS_PidController.PID_DEADBAND
                    obj.deadband = value;
                case NNS_PidController.PID_LIMITHIGH
                    obj.highLimit = value;
                case NNS_PidController.PID_LIMITLOW
                    obj.lowLimit = value;
                case NNS_PidController.PID_SETPOINT
                    obj.setpoint = value;
                    obj.cycleTime = 0;
                case NNS_PidController.PID_I_LIMITLOW
                    obj.integralLowLimit = value;
                    obj.integralLimited = (obj.integralLowLimit~=0);
                case NNS_PidController.PID_I_LIMITHIGH
                    obj.integralHighLimit = value;
                    obj.integralLimited = (obj.integralHighLimit~=0);
                    return;
            end
            
            % zero the Ki accumulator
            if(not(paramID==NNS_PidController.PID_SETPOINT))
                obj.integral = 0;
            end
        end
        
        
        %     /** Get PID controller parameters.
        %      * @param paramID What parameter to get. See the constant definitions for this class.
        %      * @return The requested parameter value
        %      *  @see #setPIDParam
        %      */
        function retval = getPIDParam(obj, paramID)
            retval = 0.0;
            switch (paramID)
                case NNS_PidController.PID_KP
                    retval=obj.Kp;
                    
                case NNS_PidController.PID_KI
                    retval=obj.Ki;
                    
                case NNS_PidController.PID_KD
                    retval=obj.Kd;
                    
                case NNS_PidController.PID_RAMP_POWER
                    retval=obj.power;
                    
                case NNS_PidController.PID_RAMP_THRESHOLD
                    retval=obj.rampThresold;
                    
                case NNS_PidController.PID_DEADBAND
                    retval = obj.deadband;
                    
                case NNS_PidController.PID_LIMITHIGH
                    retval = obj.highLimit;
                    
                case NNS_PidController.PID_LIMITLOW
                    retval = obj.lowLimit;
                    
                case NNS_PidController.PID_SETPOINT
                    retval = obj.setpoint;
                    
                case NNS_PidController.PID_I_LIMITLOW
                    retval = obj.integralLowLimit ;
                    
                case NNS_PidController.PID_I_LIMITHIGH
                    retval = obj.integralHighLimit;
                    
                case NNS_PidController.PID_I
                    retval = obj.integral;
                    
                case NNS_PidController.PID_PV
                    retval = obj.PV;
            end
        end
        
        %     /** Freeze or resume integral accumulation. If frozen, any pre-existing integral accumulation is still used in the MV calculation. This
        %      * is useful for disabling the integral function until the PV has entered the controllable region [as defined by your process
        %      * requirements].
        %      * <P>This is one methodology to manage integral windup. This is <tt>false</tt> by default at instantiation.
        %      *
        %      * @param status <tt>true</tt> to freeze, <tt>false</tt> to thaw
        %      * @see #isIntegralFrozen
        %      */
        function freezeIntegral(obj, status)
            obj.disableIntegral = status;
        end
        
        %     /**
        %      *
        %      * @return <code>true</code> if the integral accumulation is frozen
        %      * @see #freezeIntegral
        %      */
        function is = isIntegralFrozen(obj)
            is = obj.disableIntegral;
        end
        
        %     /**
        %      * Do the PID calc for a single iteration. Your implementation must provide the delay between calls to this method if you have
        %      * not set one with <code>setDelay()</code> or in the constructor.
        %      * @param processVariable The PV value from the process (sensor reading, etc.).
        %      * @see #setDelay
        %      * @return The Manipulated Variable <code>MV</code> to input into the process (motor speed, etc.)
        %      */
        function outputMV = doPID(obj, processVariable)
            obj.PV = processVariable;
            
            if (obj.cycleTime==0)
                obj.cycleTime = java.lang.System.currentTimeMillis();
                outputMV = 0;
                return;
            end
            
            obj.error = obj.setpoint - processVariable;
            if(abs(obj.error)<=obj.deadband)
                obj.error = 0;
            end
            
            if (~obj.disableIntegral)
                obj.integral = obj.integral + obj.Ki * obj.error * obj.dt;
            end
            
            if (obj.integralLimited)
                if (obj.integral>obj.integralHighLimit)
                    obj.integral = obj.integralHighLimit;
                end
                if (obj.integral<obj.integralLowLimit)
                    obj.integral = obj.integralLowLimit;
                end
            end
            
            obj.derivative = ((obj.error - obj.previous_error))/obj.dt;
            outputMV = (obj.Kp*obj.error + obj.integral + obj.Kd*obj.derivative);
            
            if (outputMV>obj.highLimit)
                outputMV=obj.highLimit;
            end
            
            if (outputMV<obj.lowLimit)
                outputMV=obj.lowLimit;
            end
            
            obj.previous_error = obj.error;
            %             outputMV=obj.rampOut(outputMV);
            
            obj.cycleCount = obj.cycleCount + 1;
            % global time it took to get back to this statement
            %             obj.dt = (java.lang.System.currentTimeMillis() - obj.cycleTime);
            %             obj.cycleTime = java.lang.System.currentTimeMillis();
            
            %return outputMV;
        end
        
        function ovOut = rampOut(obj, ov)
            if (obj.power==0 || obj.rampThresold==0)
                ovOut = ov;
                return;
            end
            if (Math.abs(ov)>obj.rampThresold)
                ovOut = ov;
                return;
            end
            
            workingOV=((abs(ov)^obj.power) / obj.rampExtent * obj.rampThresold);
            if(ov<0)
                ovOut = -1*workingOV;
            else
                ovOut = workingOV;
            end
        end
        
        %     /**
        %      * Set the desired delay before <code>doPID()</code> returns. Set to zero to effectively disable.
        %      *
        %      * @param msdelay Delay in milliseconds
        %      * @see #getDelay
        %      */
        function setDelay(obj, msdelay)
            obj.msdelay = msdelay;
        end
        
        %     /**
        %      * Returns the <code>doPID()</code> timing delay.
        %      *
        %      * @return The delay set by <code>setDelay()</code>
        %      * @see #setDelay
        %      */
        function val = getDelay(obj)
            val = obj.msdelay;
        end
        
        function set.dt(obj, newDt)
            obj.dt = abs(newDt);
        end
    end
end

