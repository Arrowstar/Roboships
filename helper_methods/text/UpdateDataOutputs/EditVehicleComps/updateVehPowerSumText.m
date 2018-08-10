function updateVehPowerSumText(ship, handles)
    if(isvalid(handles.vehPowerDataText))
        [netPower, powerUsed, powerGen] = ship.getNetPower();

        vehPwrSumStr = {};
        vehPwrSumStr{end+1} = sprintf('%s %10.2f W', paddStr('Power Generated =', 25), powerGen);
        vehPwrSumStr{end+1} = sprintf('%s %10.2f W', paddStr('Max. Power Draw =', 25), powerUsed);
        vehPwrSumStr{end+1} = sprintf('%s %10.2f W', paddStr('Power Margin    =', 25), netPower);

        set(handles.vehPowerDataText,'String',vehPwrSumStr);

        if(netPower >= 0)
            set(handles.vehPowerDataText,'ForegroundColor','k');
        else
            set(handles.vehPowerDataText,'ForegroundColor','r');
        end
    end