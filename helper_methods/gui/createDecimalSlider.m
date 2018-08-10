function [hC, fH] = createDecimalSlider(hFig, resolution, position, min, max, value, majorTickSpace, minorTickSpace)
    factor = 1/resolution;
    
    sMin = min*factor;
    sMax = max*factor;
    sValue = value*factor;
    sMajorTick = majorTickSpace*factor;
    sMinorTick = minorTickSpace*factor;
    
    hC = uicomponent(hFig, 'style','javax.swing.jslider','position',position);
    hC.JavaComponent.setPaintLabels(true);
    hC.JavaComponent.setPaintTicks(true);
    hC.JavaComponent.setMinimum(sMin);
    hC.JavaComponent.setMaximum(sMax);
    hC.JavaComponent.setValue(sValue);
    hC.JavaComponent.setMajorTickSpacing(sMajorTick);
    hC.JavaComponent.setMinorTickSpacing(sMinorTick);
    hC.JavaComponent.setExtent(0);
    hC.JavaComponent.SnapToTicks(false);
    hC.Interruptible = 'off';
    hC.BusyAction = 'cancel';
    
    fH = @(src,evt) setUD(src,evt, hC, factor);
	fH(hC.JavaComponent,[]);
    
    labels = java.util.Hashtable();
    for(tick = sMin:sMajorTick:sMax) %#ok<*NO4LP>
        num = tick/factor;
        str = num2str(num);
        labels.put(cast(tick,'int32'), javax.swing.JLabel(str));
    end
    hC.JavaComponent.setLabelTable(labels);
end

function setUD(hjSlider,~, hC, factor)
    hC.UserData = hjSlider.getValue()/factor;
    hjSlider.ToolTipText = num2str(hC.UserData,'%.3f');
end 