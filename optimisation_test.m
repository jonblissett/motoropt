k = [pi; 2]; % some constants
fun = @(x) f_test(x(1),x(2),k(1),k(2));   % wrapper function

x0 = [-.5; 0.5];

options = optimoptions('fminunc','Algorithm','quasi-newton');
options.Display = 'iter';
[x, fval, exitflag, output] = fminunc(fun,x0,options);

[X,Y] = meshgrid(-2:.1:2, -2:.1:2);
Z = X .* exp(-X.^2 - Y.^2);
surf(X,Y,Z)