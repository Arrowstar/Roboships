classdef NNS_BasicPowerGenerator < NNS_AbstractPowerSource
    %NNS_BasicPowerGenerator Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id double
        
        ship NNS_PropagatedObject;
        drawer NNS_AbstractPropagatedObjectDrawer
    end
    
    properties(SetObservable) 
        maxPowerGen double
        relPos double  = [0;0];         % m - relative to the origin of vessel it's mounted on
    end
    
    properties(Constant)
        maximumAllowedMaxPowerGen = 10000;
        typeName char = 'Basic Power Generator';
    end
    
    methods
        function obj = NNS_BasicPowerGenerator(maxPowerGen, relPos, ship)
            obj.maxPowerGen = maxPowerGen;
            obj.ship = ship;
            obj.relPos = relPos;
            
            obj.id = rand();
            obj.drawer = NNS_BasicPowerGeneratorDrawer(ship,obj);
        end
        
        function initializeComponent(obj)
            %nothing
        end

        function copiedComp = copy(obj)
            copiedComp = obj.getDefaultBasicPowerGenerator(obj.ship);
            copiedComp.maxPowerGen = obj.maxPowerGen;
            
            obj.ship.components.addComponent(copiedComp);
        end
        
        function mass = getMass(obj)
            mass = 300*(pi*obj.getCompRadiusForPower()^2);
        end
        
        function set.maxPowerGen(obj, newMaxPowerGen)
            obj.maxPowerGen = newMaxPowerGen;
            notify(obj,'ShipEditorCompNeedsRedraw');
        end
        
        function power = getPowerDrawGen(obj)
            power = obj.maxPowerGen;
        end
        
        function drawObjectOnAxes(obj, hAxes)
            obj.drawer.drawObjectOnAxes(hAxes);
        end
        
        function destroyGraphics(obj)
            obj.drawer.destroyGraphics();
        end
        
        function str = getInfoStrForComponent(obj)
            str = {};
            str{end+1} = sprintf('%s %10.3f W',       paddStr('Power Generated =', 25), obj.getPowerDrawGen());
            str{end+1} = getShipCompEditorRightHRule();
            str{end+1} = sprintf('%s %10.3f m',       paddStr('Radius          =', 25), obj.getCompRadiusForPower());
            str{end+1} = sprintf('%s %10.3f kg',      paddStr('Mass            =', 25), obj.getMass());
            str{end+1} = sprintf('%s [%.2f, %.2f] m', paddStr('Position (X,Y)  =', 25), obj.relPos(1), obj.relPos(2));
        end
        
        function hFig = createCompPropertiesEditorFigure(obj,handlesForShipCompEditUI)
            fH = @(src,evt) obj.compUpdated(src,evt, handlesForShipCompEditUI);
            pwrGenL = addlistener(obj,'maxPowerGen','PostSet',fH);
            
            hFig = basicPowerGeneratorEditorGUI(obj);
            hFig.CloseRequestFcn = @(src, evt) obj.powerGenEditorCloseReqFunc(src, evt, pwrGenL);
        end
        
        function radius = getCompRadiusForPower(obj)
            power = obj.getPowerDrawGen();
            radius = 0.00005*abs(power)+0.1;
        end
        
        function charSize = getCharacteristicSizeForComp(obj)
            charSize = obj.getCompRadiusForPower();
        end
        
        function str = getShortCompName(obj)
            comps = obj.ship.components.getPowerSrcComponents();
            ind = find(comps == obj,1,'first');
            str = sprintf('Pwr[%i]',ind);
        end
    end
    
    methods(Static)
        function powerGen = getDefaultBasicPowerGenerator(ship)
            powerGen = NNS_BasicPowerGenerator(9700, [0;0], ship);
        end
        
        function compUpdated(~,~,handles)
            updateDataDisplays(handles);
        end
        
        function powerGenEditorCloseReqFunc(src, ~, pwrGenL)
            delete(pwrGenL);
            delete(src);
        end
    end
end

