function updateVehDynSumText(ship, handles)
    if(isvalid(handles.vehDynDataText))
        [mass, thrust, maxAcc, termVel] = getShipLinearTermVel(ship);

        momInert = ship.getMomentOfInertia();
        torque = ship.basicPropagator.getMaximumTorque();
        maxRotAcc = rad2deg(torque/momInert);
        maxRotRate = rad2deg(sqrt((2 * torque)/(ship.getRotCdA()*997)));

        vehDynSumStr = {};
        vehDynSumStr{end+1} = sprintf('%s %10.2f kg',       paddStr('Total Mass    =', 25), mass);
        vehDynSumStr{end+1} = sprintf('%s %10.2f N',        paddStr('Thrust Avail. =', 25), thrust);
        vehDynSumStr{end+1} = sprintf('%s %10.2f m/s/s',    paddStr('Max. Accel.   =', 25), maxAcc);
        vehDynSumStr{end+1} = sprintf('%s %10.2f m/s',      paddStr('Max. Speed    =', 25), termVel);
        vehDynSumStr{end+1} = getShipCompEditorRightHRule();
        vehDynSumStr{end+1} = sprintf('%s %10.2f kg*m^2',   paddStr('Mom. of Inert.   =', 25), momInert);
        vehDynSumStr{end+1} = sprintf('%s %10.2f N-m',      paddStr('Torque Avail.    =', 25), torque);
        vehDynSumStr{end+1} = sprintf('%s %10.2f deg/s/s',  paddStr('Max. Rot. Accel. =', 25), maxRotAcc);
        vehDynSumStr{end+1} = sprintf('%s %10.2f deg/s',    paddStr('Max. Rot. Rate   =', 25), maxRotRate);

        set(handles.vehDynDataText,'String',vehDynSumStr);
    end
end