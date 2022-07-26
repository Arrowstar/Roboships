classdef NNS_NnAiShipController < NNS_AbstractShipController & NNS_AbstractPoweredComponent
    %NNS_NnAiShipController Summary of this class goes here
    %   Detailed explanation goes here

    properties
        ship NNS_PropagatedObject

        rlAgent

        id double
        relPos double = [0;0]         % m - relative to the origin of vessel it's mounted on
    end

    properties(Constant)
        typeName char = 'Neural Network Controller'
    end

    methods
        function obj = NNS_NnAiShipController(ship)
            arguments
                ship(1,1) NNS_Ship;
            end

            obj.ship = ship;
            obj.id = rand();
            
            obj.drawer = NNS_NnAiShipControllerDrawer(ship, obj);

            obsInfo = obj.ship.getObservationInfo();
            actInfo = obj.ship.getActionInfo();

            for(i=1:length(actInfo))
                actInfoElems{i} = actInfo(i).Elements(:)'; %#ok<AGROW> 
            end
            actions = num2cell(combvec(actInfoElems{:})', 2);
            actInfo = rlFiniteSetSpec(actions);

            initOpts = rlAgentInitializationOptions("NumHiddenUnit",64, "UseRNN",true);
            obj.rlAgent = rlPPOAgent(obsInfo,actInfo,initOpts);
        end

        function initializeComponent(obj)
            %nop
        end

        function executeNextOperation(obj)
            obs = obj.ship.getObservation();
            actions = obj.rlAgent.getAction(obs);
            actions = actions{1};
            curTime = obj.ship.arena.simClock.curSimTime;

            %loop over components here
            nnComps = obj.ship.components.getNeuralNetworkCapableComponents();
            aInd = 1;
            for(i=1:length(nnComps)) %#ok<*NO4LP> 
                nnComp = nnComps(i);
                compActInfo = nnComp.getActionInfo();

                if(not(isempty(compActInfo)))
                    numActions = prod(compActInfo.Dimension);
                    subActions = actions(aInd : aInd + numActions -1);
                    nnComp.execAction(subActions, curTime);
                end
            end
        end

        function mass = getMass(obj)
            mass = 300*(pi*obj.getCompRadiusForPower()^2);
        end
        
        function charSize = getCharacteristicSizeForComp(obj)
            charSize = obj.getCompRadiusForPower();
        end

        function drawObjectOnAxes(obj, hAxes)
            if(isempty(obj.drawer))
                obj.drawer = NNS_NnAiShipControllerDrawer(obj.ship, obj);
            end
            
            if(isempty(obj.drawer.ship))
                obj.drawer.ship = obj.ship;
            end
            
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
        
        function str = getInfoStrForComponent(obj)
            str = {};
            
            str{end+1} = sprintf('%s %10.3f W',       paddStr('Power Used         =', 25), abs(obj.getPowerDrawGen()));
            str{end+1} = sprintf('%s %10.3f m',       paddStr('Radius             =', 25), obj.getCompRadiusForPower());
            str{end+1} = sprintf('%s %10.3f kg',      paddStr('Mass               =', 25), obj.getMass());
            str{end+1} = sprintf('%s [%.2f, %.2f] m', paddStr('Position (X,Y)     =', 25), obj.relPos(1), obj.relPos(2));
        end
        
        function createCompPropertiesEditorFigure(obj, handlesForShipCompEditUI)
%             handles = handlesForShipCompEditUI;
%             
%             set(handles.shipCompEditorGUI,'Visible','off');
%             obj.ship = shipProgramEditorGUI(obj.ship, obj);
%             set(handles.shipCompEditorGUI,'Visible','on');
% 
%             setappdata(handles.shipCompEditorGUI,'ship',obj.ship);
        end
        
        function power = getPowerDrawGen(obj)
            power = -1000;
        end
        
        function radius = getCompRadiusForPower(obj)
            radius = 0.25;
        end

        function tf = usesPidController(obj)
            tf = false;
        end

        function agent = getAgent(obj)
            agent = obj.rlAgent;
        end
    end
end