function controller = getController(shipProgramEditorGUI)
%     ship = getappdata(shipProgramEditorGUI,'ship');
%     controller = ship.components.getControllerComps();
%     controller = controller(1);

    controller = getappdata(shipProgramEditorGUI,'controller');
end