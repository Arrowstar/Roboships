function comp = getSelectedComp(componentSelCombo, hFig)
    contents = cellstr(get(componentSelCombo,'String'));
    compsStr = contents{get(componentSelCombo,'Value')};
    
    ship = getappdata(hFig,'ship');
    shipDrawComps = ship.components.getDrawableComponents();
    
    if(strcmpi(compsStr,'Ship'))
        comp = ship;
    else
        text = regexp(compsStr,'<(.*)>','tokens');
        text = text(~cellfun('isempty',text));
        text = text{1}{1};
        
        comp = NNS_VehicleComponent.empty(0,0);
        if(not(isempty(text)))
            for(i=1:length(shipDrawComps)) %#ok<*NO4LP>
                if(strcmpi(text, shipDrawComps(i).getShortCompName()))
                    comp = shipDrawComps(i);
                end
            end
        end
    end
end