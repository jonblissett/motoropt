function z = f_test(x,y,k1,k2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    z = k1*x.*exp(-x.^2-y.^2)+k2*(x.^2+y.^2)/20;
end

