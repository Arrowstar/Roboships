function selSubR = getSelectedSubroutine(handles)
    controller = getController(handles.shipProgramEditorGUI);
    
    subRInd = handles.subroutineCombo.Value;
    selSubR = controller.getSubroutineForIndex(subRInd);
end