function sortAxes2dImpolyChildren(hAxes)
    areaAxChildMap = {};
    axChildren = get(hAxes,'Children');
    
    for(i=1:length(axChildren)) %#ok<*NO4LP>
        axChild = axChildren(i);
        if(isprop(axChild,'Tag') && strcmpi(axChild.Tag,'impoly'))
            verts = axChild.Children(end).Vertices;
            area = polyarea(verts(:,1),verts(:,2));
        else
            area = -1;
        end
        areaAxChildMap(end+1,:) = {axChild,area};  %#ok<AGROW>
    end
    sortedAxChildren = sortrows(areaAxChildMap,2,'ascend');

    for(i=1:size(sortedAxChildren,1))
        axChildren(axChildren == sortedAxChildren{i,1}) = [];
    end

    for(i=1:size(sortedAxChildren,1))
        axChildren(end+1) = sortedAxChildren{i,1};  %#ok<AGROW>
    end
    set(hAxes,'Children', axChildren);
end