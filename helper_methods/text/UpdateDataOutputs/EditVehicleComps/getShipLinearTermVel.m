function [mass, thrust, maxAcc, termVel] = getShipLinearTermVel(ship)
    mass = ship.getMass();
    thrust = ship.basicPropagator.getMaximumThrust();
    maxAcc = thrust/mass;
    termVel = sqrt((2 * thrust)/(ship.getLinearCdA()*997));
end