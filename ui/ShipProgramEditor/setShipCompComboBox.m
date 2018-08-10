function setShipCompComboBox(ship, componentSelCombo)
    shipDrawComps = ship.components.getDrawableComponents();
    compsStr = {'Ship'};
    
    objMap = NNS_ObjectToControllerObjectMap.getMap();
    for(i=1:length(shipDrawComps)) %#ok<*NO4LP>
        comp = shipDrawComps(i);
        
        if(not(isempty(objMap.getAllEntriesForCompClass(class(comp)))))
            compsStr(end+1) = {sprintf('%s <%s>', comp.typeName, comp.getShortCompName())}; %#ok<AGROW>
        end
    end
    set(componentSelCombo,'String',compsStr);