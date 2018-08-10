function updateDataDisplays(handles)
    if(isvalid(handles.editSelCompButton) && isvalid(handles.selectedCompSumText) && isvalid(handles.selCompSumPanel))
        selComp = getappdata(handles.shipCompEditorGUI,'selectedComponent');
        ship = getappdata(handles.shipCompEditorGUI,'ship');

        updateVehDynSumText(ship, handles);
        updateVehPowerSumText(ship, handles);

        if(not(isempty(selComp)))
            handles.editSelCompButton.String = sprintf('Edit Selected Component (%s)', selComp.typeName);
            handles.selectedCompSumText.String = selComp.getInfoStrForComponent();
            handles.selCompSumPanel.Title = sprintf('Component Summary (%s: %s)', selComp.getShortCompName, selComp.typeName);
        end
    end
end