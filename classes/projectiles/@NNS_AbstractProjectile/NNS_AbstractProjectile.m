classdef(Abstract = true) NNS_AbstractProjectile < NNS_PropagatedObject & NNS_IsDetectable
    %NNS_AbstractProjectile Summary of this class goes here
    
    properties
        ownerShip NNS_Ship
        effectiveRng double = 0; 
    end
    
    methods
        damage = getBaseDamage(obj);

        function checkForHitAndDoDamage(obj)
            %check for collisions
            shootPropObjs = obj.propObjs.getShootablePropObjects();
            pos = obj.stateMgr.position;
            
            shootPropObjs = shootPropObjs(shootPropObjs ~= obj & shootPropObjs ~= obj.ownerShip);
            for(i=1:length(shootPropObjs)) %#ok<*NO4LP>
                shootPropObj = shootPropObjs(i);
                
                p1 = pos;
                p2 = shootPropObj.stateMgr.position;
                rng = hypot(p2(1)-p1(1), p2(2)-p1(2));
                obj.minRng = min(obj.minRng, rng);
                
                if(rng < 10)
                    verts = shootPropObj.getVertsForHitCheck();

                    hitTF = zeros(1,size(verts,3));
                    for(j=1:size(verts,3))
                        hitTF(j) = inpolygon(pos(1), pos(2), verts(:,1,j), verts(:,2,j));
                        
                        if(obj.effectiveRng > 0)
                            D = pdist2(pos',[verts(:,1,j), verts(:,2,j)],'euclidean');
                            count = sum(D <= obj.effectiveRng);
                                                       
                            hitTF(j) = hitTF(j) + count;
                        end
                        
                    end

                    if(any(hitTF))
                        shootPropObj.takeHit(obj);
                        
                        relPosToShip = p1 - p2;
                        createTime = obj.clock.curSimTime;
                        explosionEffect = NNS_ExplosionEffect(shootPropObj, relPosToShip, createTime);
                        obj.propObjs.addPropagatedObject(explosionEffect);
                        
                        obj.awardMinRngPoints();

                        obj.setInactiveAndRemove();
                        fprintf('Projectile from %s has hit %s\n', obj.ownerShip.name, shootPropObj.name);
                    end
                end
            end
        end
        
        function rngPts = getPtsAwardedByRng(obj)
            maxPtsRng = 100; %m
            rngPts = (-obj.baseDamage/maxPtsRng)*obj.minRng + obj.baseDamage;
        end
        
        function awardMinRngPoints(obj)
            if(obj.active == true)
                rngPts = obj.getPtsAwardedByRng();
                if(rngPts > 0)
                    obj.ownerShip.addPointsToScore(rngPts);
                end
            end 
        end
    end
end

