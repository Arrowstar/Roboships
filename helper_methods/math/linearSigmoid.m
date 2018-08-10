function [y] = linearSigmoid(x, lb, ub)
%linearSigmoid Summary of this function goes here
    if(x < lb)
        y = lb;
    elseif(x >= lb && x <= ub)
        y = x;
    elseif(x > ub)
        y = ub;
    end
end

