function [a, b, c, d] = motor_saturation_coeff(kt, i_pk, t_pk, x2, y2)
%UNTITLED8 Summary of this function goes here
    % Call with rms values, returns peak values
    % T = a*I.^3+b*I.^2+kt*I+0;
    % i_pk = 987.1
    % t_pk = 308.64
    % kt = 0.366
    % x2 = 493.6  % stall current continuous
    % y2 = 178.47  % stall torque continuous

    b = (y2 + x2 ^ 3 / i_pk ^ 3 * (kt * i_pk - t_pk) - kt * x2) / (x2 ^ 2 - x2 ^ 3 / i_pk);
    a = 1.0 / i_pk ^ 3 * (t_pk - kt * i_pk - b * i_pk ^ 2);

    a = a / (2 * 2 ^ 0.5);
    b = b/2;
    c = kt / (2 ^ 0.5);
    d = 0;

end

