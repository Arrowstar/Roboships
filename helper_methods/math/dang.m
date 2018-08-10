function [angle] = dang(a,b)
%dang Summary of this function goes here
%   Detailed explanation goes here
    angle = atan2(norm(crossARH(a,b)),dotARH(a,b));
end

