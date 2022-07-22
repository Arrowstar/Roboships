classdef NNS_NodeCntrlrOperationDrawer < NNS_AbstractControllerCommandDrawer
    %NNS_StartCntrlrOperationDrawer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cmd NNS_AbstractControllerOperation
    end
    
    methods
        function obj = NNS_NodeCntrlrOperationDrawer(cmd)
            obj.cmd = cmd;
            
            obj.squareWidth = 0.5;
            obj.squareHeight = 0.5;
            obj.circleDiam = 0.5;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            drawObjectOnAxes@NNS_AbstractControllerCommandDrawer(obj, hAxes);
        end
        
        function destroyGraphics(obj)
            destroyGraphics@NNS_AbstractControllerCommandDrawer(obj);
        end
        
        function str = getTitleTextStr(obj)
            str = '';
        end
        
        function str = getInfoTextStr(obj)
            str = '';
        end
    end
    
    methods(Access=protected)
        function createGenericCmdBlock(obj, hAxes)
            cPos = obj.cmd.canvassPos;
                        
            a = linspace(0,2*pi,25);
            squareCmd = (obj.circleDiam/2)*[cos(a)', sin(a)'] + cPos + [obj.squareWidth/2,obj.squareHeight/2];
            
            obj.cmdPoly = createCmdPoly(obj, hAxes, squareCmd);

            for(i=1:obj.cmd.numOutputs) %#ok<*NO4LP>
                [circPolyOut,hLineOut] = getOutputCircle(obj, hAxes, i, obj.cmdPoly, cPos, squareCmd);
                obj.circPoly(i) = circPolyOut;
                obj.hLine(i) = hLineOut;
            end
            
            obj.cmdPoly.addNewPositionCallback(@(p) obj.setImObjUserDataToCurPos(p, obj.cmdPoly));
            obj.cmdPoly.setPosition(squareCmd);
        end
        
        function cmdPoly = createCmdPoly(obj, hAxes, circPos)
            cmdPoly = impoly(hAxes, circPos);
            set(cmdPoly,'Tag','impoly_Node');
            
            setVerticesDraggable(cmdPoly,false);
            obj.configureImObjs(cmdPoly, 'k', 'w', 0.5, []);
            obj.setImObjUserDataToCurPos([],cmdPoly);
            cmdPoly.addNewPositionCallback(@(p) obj.updateCmdCanvassPosition(p, obj.cmd));
            cmdPoly.setPositionConstraintFcn(makeConstrainToRectFcn('impoly',get(hAxes,'XLim'),get(hAxes,'YLim')));
        end
    end
end