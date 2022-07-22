classdef NNS_StateManager < matlab.mixin.SetGet
    %NSS_StateManager Keeps track of the current object state: position and
    %heading
    
    properties
        position(2,1) double %meters [2x1]
        velocity(2,1) double %m/s [2x1]
        heading double  %radians
        angRate double  %rad/s
    end
    
    methods
        function obj = NNS_StateManager()
            %NSS_StateManager Construct an instance of this class
            obj.position = [0;0];
            obj.velocity = [0;0];
            obj.heading = 0;
            obj.angRate = 0;
        end
        
        function set.position(obj, newPos)
            if(size(newPos) == [2,1]) %#ok<BDSCA>
                obj.position = newPos;
            else
                error('The expected size of all position vectors in NSS_StateManager is 2x1.  Entered: %f x %f', size(newPos));
            end
        end
        
        function set.velocity(obj, newVel)
            if(size(newVel) == [2,1]) %#ok<BDSCA>
                obj.velocity = newVel;
            else
                error('The expected size of all velocity vectors in NSS_StateManager is 2x1.  Entered: %f x %f', size(newVel));
            end
        end
        
        function set.heading(obj, newHeading)
            if(size(newHeading) == [1,1]) %#ok<BDSCA>
                obj.heading = angleZero2Pi(newHeading);
            else
                error('The expected size of a heading in NSS_StateManager is 1x1.  Entered: %f x %f', size(newHeading));
            end
        end
        
        function set.angRate(obj, newAngRate)
            if(size(newAngRate) == [1,1]) %#ok<BDSCA>
                obj.angRate = newAngRate;
            else
                error('The expected size of a angular rate in NSS_StateManager is 1x1.  Entered: %f x %f', size(newAngRate));
            end
        end
        
        function rotMat = getRotMatrixForHeading(obj)
            hd = obj.heading;
            cHd = cos(hd);
            sHd = sin(hd);
            rotMat = [cHd, -sHd; 
                      sHd,  cHd];
        end
        
        function hdgUnitVect = getHeadingUnitVector(obj)
            hdgUnitVect = obj.getRotMatrixForHeading() * [1;0];
        end
        
        function setRandomizedPositionAndHeading(obj, positionBnds, headingBnds)
            xBnd = (2/3)*positionBnds(1:2);
            yBnd = (2/3)*positionBnds(3:4);
            
            if(xBnd(1) > xBnd(2) ||...
               yBnd(1) > yBnd(2) ||...
               headingBnds(1) > headingBnds(2))
                error('When setting random position and heading in NSS_StateManager, one lower bound was greater than its upper bound.');
            end
            
            rndX = xBnd(1) + (xBnd(2)-xBnd(1))*rand();
            rndY = yBnd(1) + (yBnd(2)-yBnd(1))*rand();
            rndHdg = headingBnds(1) + (headingBnds(2)-headingBnds(1))*rand();
            
            obj.position = [rndX;rndY];
            obj.heading = angleZero2Pi(deg2rad(rndHdg));
            obj.velocity = [0;0];
            obj.angRate = 0;
        end
        
        function setZeroPositionAndHeadingAndNoVel(obj)
            obj.position = [0;0];
            obj.heading = 0;
            obj.velocity = [0;0];
            obj.angRate = 0;
        end
    end
end

