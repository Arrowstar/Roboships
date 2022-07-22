classdef(Abstract) NNS_AbstractControllerCommandDrawer < matlab.mixin.SetGet
    %NNS_AbstractControllerCommandDrawer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Abstract)
        cmd NNS_AbstractControllerOperation
    end
    
    properties
        updateSecondNode logical = true;
    end

    properties(Access=protected)
        cmdPoly impoly
        titleText matlab.graphics.primitive.Text %matlab.graphics.shape.TextBox
        titleTextBg matlab.graphics.primitive.Patch
        infoText matlab.graphics.primitive.Text  %matlab.graphics.shape.TextBox
        infoTextBg matlab.graphics.primitive.Patch
        circPoly imellipse
        hLine matlab.graphics.chart.primitive.Quiver; %matlab.graphics.primitive.Line
        
        squareWidth = 3;
        squareHeight = 1.5;
        circleDiam = 0.5;
        
        outputLineColors = {'k'};
    end
    
    methods
        function drawObjectOnAxes(obj, hAxes)
            if(not(isempty(obj.cmdPoly)) && isvalid(obj.cmdPoly) && ...
               not(isempty(obj.titleText)) && isvalid(obj.titleText) && ...
               not(isempty(obj.infoText)) && isvalid(obj.infoText) && ...
               not(isempty(obj.titleTextBg)) && isvalid(obj.titleTextBg) && ...
               not(isempty(obj.infoTextBg)) && isvalid(obj.infoTextBg) && ...
               not(isempty(obj.circPoly)) && isvalid(obj.circPoly) && ...
               not(isempty(obj.hLine)) && isvalid(obj.hLine))
           
                set(obj.cmdPoly,'Parent',hAxes);
                set(obj.titleText,'Parent',hAxes);
                set(obj.infoText,'Parent',hAxes);
                set(obj.titleTextBg,'Parent',hAxes);
                set(obj.infoTextBg,'Parent',hAxes);
                set(obj.circPoly,'Parent',hAxes);
                set(obj.hLine,'Parent',hAxes);
            else
                obj.createGenericCmdBlock(hAxes);
                
%                 c = get(hAxes,'children');
%                 h = findobj(c, '-not', 'Type','hggroup');
%                 for(i=1:length(h))
%                     uistack(h(i),'bottom');
%                 end
%                 
%                 h2 = findobj(c, 'Tag', 'impoly');
%                 for(i=1:length(h2))
%                     uistack(h2(i),'bottom');
%                 end
            end
        end
        
        function destroyGraphics(obj)
            delete(obj.cmdPoly)
            delete(obj.titleText)
            delete(obj.titleTextBg);
            delete(obj.infoText)
            delete(obj.infoTextBg);
            delete(obj.circPoly)
            delete(obj.hLine)
        end
        
        function pos = getCmdBoxPosition(obj)
            pos = obj.cmdPoly.getPosition();
        end
        
        function [pos] = getCirclePositions(obj)
            pos = zeros(length(obj.circPoly),4);
            for(i=1:length(obj.circPoly))
                pos(i,:) = obj.circPoly(i).getPosition(); 
            end
        end
        
        str = getTitleTextStr(obj);
        
        str = getInfoTextStr(obj);
        
        function refreshText(obj)
            if(not(isempty(obj.titleText)))
                obj.titleText.String = obj.getTitleTextStr();
            end
            
            infoStr = obj.getInfoTextStr();
            
            if(length(infoStr) > 50)
                infoStr = [infoStr(1:50), '...'];
            end
            
            if(not(isempty(obj.infoText)))
                obj.infoText.String = infoStr;
            end
        end
        
        function setSelected(obj, tf)
            if(tf)
                edgeWidth = 2;
            else
                edgeWidth = 0.5;
            end
            
            obj.configureImObjs(obj.cmdPoly, 'k', 'w', edgeWidth, 'top');
        end
    end
    
    methods(Access=protected)
        function createGenericCmdBlock(obj, hAxes)
            cPos = obj.cmd.canvassPos;
            
            squareCmd = [cPos(1),cPos(2);
                cPos(1)+obj.squareWidth,cPos(2);
                cPos(1)+obj.squareWidth,cPos(2)+obj.squareHeight;
                cPos(1),cPos(2)+obj.squareHeight];
            
            obj.cmdPoly = createCmdPoly(obj, hAxes, squareCmd);
            [obj.titleText,obj.titleTextBg] = getTitleText(obj, hAxes, obj.cmdPoly);
            
            [obj.infoText, obj.infoTextBg] = getInfoText(obj, hAxes, obj.cmdPoly);
                        
            for(i=1:obj.cmd.numOutputs)
                [circPolyOut,hLineOut] = getOutputCircle(obj, hAxes, i, obj.cmdPoly, cPos, squareCmd);
                obj.circPoly(i) = circPolyOut;
                obj.hLine(i) = hLineOut;
            end
            
            obj.cmdPoly.addNewPositionCallback(@(p) obj.setImObjUserDataToCurPos(p, obj.cmdPoly));
            obj.cmdPoly.setPosition(squareCmd);
        end
        
        function cmdPoly = createCmdPoly(obj, hAxes, squareCmd)
            cmdPoly = impoly(hAxes, squareCmd);
            setVerticesDraggable(cmdPoly,false);
            obj.configureImObjs(cmdPoly, 'k', [0 0 0 0], 0.5, 'bottom');
            obj.setImObjUserDataToCurPos([],cmdPoly);
            cmdPoly.addNewPositionCallback(@(p) obj.updateCmdCanvassPosition(p, obj.cmd));
            cmdPoly.setPositionConstraintFcn(makeConstrainToRectFcn('impoly',get(hAxes,'XLim'),get(hAxes,'YLim')));
            
            c = get(cmdPoly,'Children');
            cm = uicontextmenu(hAxes.Parent);
            cmenu_obj = findobj(c,'Type','line','-or','Type','patch');  
            set(cmenu_obj,'uicontextmenu',cm);
        end

        function [titleText, titleTextBg] = getTitleText(obj, hAxes, cmdPoly)           
            titlePosData = [0,obj.squareHeight*(3/4), obj.squareWidth, obj.squareHeight*(1/4)];
            
            bgPatchX = [titlePosData(1), titlePosData(1) + titlePosData(3), titlePosData(1) + titlePosData(3), titlePosData(1)]';
            bgPatchY = [titlePosData(2), titlePosData(2), titlePosData(2) + titlePosData(4), titlePosData(2) + titlePosData(4)]';
            titleTextBg = patch(hAxes, bgPatchX,bgPatchY,'b', 'PickableParts','none');
            cmdPoly.addNewPositionCallback(@(p) obj.updatePositionOfPatchOnDrag(p, titleTextBg, [bgPatchX,bgPatchY]));
            
            titleText = text(hAxes, 'String',obj.getTitleTextStr(),'Position',titlePosData(1:2),...
                'Margin',0.01,'HorizontalAlignment','left','BackgroundColor','none','Color','w',...
                'PickableParts','none','Interpreter','none','VerticalAlignment','bottom');
            cmdPoly.addNewPositionCallback(@(p) obj.updatePositionOfAnnotationOnDrag(p, hAxes,titleText,titlePosData));
            
            doLoop = true;
            while(doLoop)
                extent = titleText.Extent;
                if(extent(3) > obj.squareWidth)
                    titleText.FontSize = titleText.FontSize - 0.5;
                else
                    doLoop = false;
                end
                
                if(titleText.FontSize <= 0.5)
                    doLoop = false;
                end
            end
            titleText.FontSize = titleText.FontSize;
        end
        
        function [infoText, infoTextBg] = getInfoText(obj, hAxes, cmdPoly)
            infoPosData = [0,0, obj.squareWidth, obj.squareHeight*(3/4)];
            
            bgPatchX = [infoPosData(1), infoPosData(1) + infoPosData(3), infoPosData(1) + infoPosData(3), infoPosData(1)]';
            bgPatchY = [infoPosData(2), infoPosData(2), infoPosData(2) + infoPosData(4), infoPosData(2) + infoPosData(4)]';
            infoTextBg = patch(hAxes, bgPatchX,bgPatchY,'w', 'PickableParts','none');
            cmdPoly.addNewPositionCallback(@(p) obj.updatePositionOfPatchOnDrag(p, infoTextBg, [bgPatchX,bgPatchY]));
            
            infoText = text(hAxes, 'String',obj.getInfoTextStr(),'Position',infoPosData(1:2),...
                'Margin',1,'HorizontalAlignment','left','BackgroundColor','w','Color','k',...
                'VerticalAlignment','bottom','PickableParts','none','FontSize',7,'Interpreter','none');
            cmdPoly.addNewPositionCallback(@(p) obj.updatePositionOfAnnotationOnDrag(p, hAxes,infoText,infoPosData));
        end
        
        function [circPoly,hLine] = getOutputCircle(obj, hAxes, i, cmdPoly, cPos, squareCmd)
            circPosStored = obj.cmd.outputCircCanvassPos{i};
            if(not(isempty(circPosStored)))
                circPos = circPosStored;
            else
                circPos = [cPos(1)+obj.squareWidth/2-obj.circleDiam/2, cPos(2)-2, obj.circleDiam, obj.circleDiam];
            end
            
            circPoly = imellipse(hAxes, circPos);
            obj.configureImObjs(circPoly, 'r', 'w', 0.5, 'top');
            obj.setImObjUserDataToCurPos([],circPoly);
            cmdPoly.addNewPositionCallback(@(p) obj.updatePositionOfCircOnDrag(p, cmdPoly, circPoly, 'on'));
            circPoly.setPositionConstraintFcn(makeConstrainToRectFcn('imellipse',get(hAxes,'XLim'),get(hAxes,'YLim')));
            circPoly.addNewPositionCallback(@(p) obj.updateOutputCircCanvassPosition(p, obj.cmd, i));
            set(circPoly,'UserData', i);

            lineColor = obj.outputLineColors{i};

            centerCmdPoly = [mean(squareCmd(:,1)), mean(squareCmd(:,2))];
            centerCircle = circPos(1:2) + circPos(3:4)/2;
            lineData = [centerCmdPoly;centerCircle];
            hold(hAxes,'on');
            hLine = quiver(hAxes, lineData(1,1), lineData(1,2), lineData(2,1)-lineData(1,1), lineData(2,2)-lineData(1,2), 'LineWidth',1, 'Color',lineColor,'AutoScaleFactor',1.0,'AutoScale','off', 'MaxHeadSize',0.1);
            hLine.LineStyle = '--';
            hold(hAxes,'off');
            hLine.UserData = obj.cmd.cmdTitle;
            uistack(hLine,'bottom');
            cmdPoly.addNewPositionCallback(@(p) obj.updateFirstNodeOfLineOnDrag(p, hLine, circPoly));
            circPoly.addNewPositionCallback(@(p) obj.updateSecondNodeOfLineOnDrag(p, hLine, cmdPoly));
        end
    end

    methods(Access=public)
        function [cPolyOut, cmdOut, oCmd, id] = connectCommandBlockToAnotherCommandBlock(obj, oCmd, circInd)
            if(not(isempty(oCmd.drawer)) && ...
               not(isempty(oCmd.drawer.cmdPoly)))
                oCmdPoly = oCmd.drawer.cmdPoly;
                
                oPos = oCmdPoly.getPosition();
                oCenter = [mean(oPos(:,1)), mean(oPos(:,2))];
                
                allCirPos = obj.getCirclePositions();
                circPos = allCirPos(circInd,:);

                circPos(1:2) = [oCenter(1) - obj.circleDiam/2, ...
                                oCenter(2) - obj.circleDiam/2];
                obj.circPoly(circInd).setPosition(circPos);
                set(obj.circPoly(circInd),'Visible','off');
                set(obj.circPoly(circInd),'PickableParts','none');        
                
                fH = @(p) oCmd.drawer.updatePositionOfCircleToCenterOfCmdBox(p, obj.circPoly(circInd), obj.circleDiam);
                id = oCmdPoly.addNewPositionCallback(fH);  
                fH(oPos);
                
                obj.hLine(circInd).LineStyle = '-';
                
                cPolyOut = obj.circPoly(circInd);
                cmdOut = obj.cmd;
            end
        end
        
        function circId = disConnectCommandBlockFromAnotherCommandBlock(obj, oCmd, id)
            if(not(isempty(id)))
                oCmdPoly = oCmd.drawer.cmdPoly;
                oCmdPoly.removeNewPositionCallback(id);
            end
            
            circId = [];
            for(i=1:obj.cmd.numOutputs)
                if(obj.cmd.getNextOperationForInd(i) == oCmd)
                    circId = i;
                    break;
                end
            end
            
            if(not(isempty(circId)))
                set(obj.circPoly(circId),'Visible','on');
                set(obj.circPoly(circId),'PickableParts','visible');
                set(obj.circPoly(circId),'UserData',[]);
                obj.configureImObjs(obj.circPoly(circId), 'r', 'w', 0.5, 'top');
                
                obj.hLine(circId).LineStyle = '--';
            end
        end
    end
    
    methods(Static)
        function configureImObjs(imObj, edgeColor, faceColor, edgeWidth, uistackOrder)
            if(isvalid(imObj))
                children = get(imObj,'Children');
                for(i=1:length(children)) %#ok<*NO4LP>
                    c = children(i);
                    if(isa(c,'matlab.graphics.primitive.Patch'))
                        if(not(isempty(faceColor)))
                            if(isa(faceColor,'double'))
                                c.FaceColor = faceColor(1:3);
                                if(length(faceColor) == 4)
                                    c.FaceAlpha = faceColor(4);
                                end
                            else
                                c.FaceColor = faceColor;
                            end
                        end
                        
                        if(not(isempty(edgeColor)))
                            c.EdgeColor = edgeColor;
                        end
                        
                        if(not(isempty(edgeWidth)))
                            c.LineWidth = edgeWidth;
                        end
                    elseif(isa(c,'matlab.graphics.primitive.Line'))
                        c.Visible = 'off';
                    end
                end
                
                if(not(isempty(uistackOrder)))
                    uistack(children,uistackOrder);
                end
            end
        end
    end
    
    methods(Access=protected)
        function updateSecondNodeOfLineOnDrag(obj, circPos, quiver, cmdPoly)
            if(obj.updateSecondNode)
                center = circPos(1:2) + circPos(3:4)/2;

                polyPos = cmdPoly.getPosition();
                cmdCenter = [mean(polyPos(:,1)), mean(polyPos(:,2))];

                quiver.XData(1) = cmdCenter(1);
                quiver.YData(1) = cmdCenter(2);
                quiver.UData(1) = center(1) - cmdCenter(1);
                quiver.VData(1) = center(2) - cmdCenter(2);

                NNS_AbstractControllerCommandDrawer.updateArrowheadPosition(quiver);
            end
        end
    end
    
    methods(Static, Access=protected)
        function updateCmdCanvassPosition(polyPos, cmd)
            minX = min(polyPos(:,1));
            minY = min(polyPos(:,2));
            
            cmd.canvassPos = [minX, minY];
        end

        function updateOutputCircCanvassPosition(circPos, cmd, i)            
            cmd.outputCircCanvassPos{i} = circPos;
        end
        
        function updatePositionOfAnnotationOnDrag(polyPos, hAx, hChld, relPos)
            minX = min(polyPos(:,1));
            minY = min(polyPos(:,2));
            newCPos = relPos;
            
            extent = hChld.Extent;
            newCPos(1) = newCPos(1) - extent(1) + extent(3);
            
            newCPos(1) = relPos(1) + (relPos(3) - extent(3))/2 + minX;
            newCPos(2) = relPos(2) + (relPos(4) - extent(4))/2 + minY;

            hChld.Position = newCPos(1:2);
        end
        
        function updatePositionOfPatchOnDrag(polyPos, pChld, relPos)
            minX = min(polyPos(:,1));
            minY = min(polyPos(:,2));
            newCPos = relPos;
            
            newCPos(:,1) = newCPos(:,1) + minX;
            newCPos(:,2) = newCPos(:,2) + minY;
            
            pChld.XData = newCPos(:,1);
            pChld.YData = newCPos(:,2);
        end
        
        function updatePositionOfCircOnDrag(polyPos, cPoly, circPoly, visStateForAction)
            if(strcmpi(get(circPoly,'Visible'), visStateForAction))
                posDiff = polyPos - get(cPoly,'UserData');
                posDiff = posDiff(1,:);

                circPos = circPoly.getPosition();
                circPos(1:2) = circPos(1:2) + posDiff;
                circPoly.setPosition(circPos);
            end
        end
        
        function updatePositionOfCircleToCenterOfCmdBox(polyPos, circPoly, circDiam)
            if(isvalid(circPoly))
                center = [mean(polyPos(:,1)), mean(polyPos(:,2))];

                circPos = circPoly.getPosition();
                circPos(1:2) = [center(1) - circDiam/2, ...
                                center(2) - circDiam/2];
                circPoly.setPosition(circPos);
            end
        end
        
        function updateFirstNodeOfLineOnDrag(polyPos, quiver, circPoly)
            center = [mean(polyPos(:,1)), mean(polyPos(:,2))];
                        
            circPos = circPoly.getPosition();
            circCenter = circPos(1:2) + circPos(3:4)/2;
            
            quiver.XData(1) = center(1);
            quiver.YData(1) = center(2);
            quiver.UData(1) = circCenter(1) - center(1);
            quiver.VData(1) = circCenter(2) - center(2);
            
            NNS_AbstractControllerCommandDrawer.updateArrowheadPosition(quiver);
        end
        
        function updateArrowheadPosition(quiver)            
            xDiff = quiver.UData(1)/2;
            yDiff = quiver.VData(1)/2;
            
            drawnow; %needed to populate VertexData
            newXRow = quiver.Head.VertexData(1,:)-xDiff;
            quiver.Head.VertexData(1,:) = newXRow;

            newYRow = quiver.Head.VertexData(2,:)-yDiff;
            quiver.Head.VertexData(2,:) = newYRow;
        end
        
        function setImObjUserDataToCurPos(~, imObj)
            set(imObj,'UserData',imObj.getPosition());
        end
    end
end

