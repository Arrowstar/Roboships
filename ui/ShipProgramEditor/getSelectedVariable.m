function var = getSelectedVariable(variablesListbox, shipProgramEditorGUI)
    controller = getController(shipProgramEditorGUI);
    varList = controller.getVariableList();
    
    selInd = get(variablesListbox,'Value');
    var = varList.getVariableAtIndex(selInd);