function [err, Iq] = SetCurrentForTorque(mcad, Torque_target, tol)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    err = 0;
    invoke(mcad,'SetVariable','BackEMFCalculation','False');
    invoke(mcad,'SetVariable','TorqueCalculation','False');
    invoke(mcad,'SetVariable','MagneticThermalCoupling',0);
    
    invoke(mcad,'DoMagneticCalculation');
    
    [~, T0] = invoke(mcad,'GetVariable','OnLoadDQTorque');
    [~, I0] = invoke(mcad,'GetVariable','PeakCurrent');
    
    x = zeros(7,1);
    y = zeros(7,1);
    x(1) = I0;
    y(1) = T0-Torque_target;
    
    n = 1;
    if abs(y(1)) > tol * Torque_target
        x(2) = x(1)/(y(1)+Torque_target)*Torque_target;

        invoke(mcad,'SetVariable','PeakCurrent',x(2));
        invoke(mcad,'DoMagneticCalculation');
        [~, y(2)] = invoke(mcad,'GetVariable','OnLoadDQTorque');
        y(2) = y(2) - Torque_target;

        n = 2;
        iterate = abs(y(n)) > tol * Torque_target;
        while iterate
            n = n + 1;
            %https://en.wikipedia.org/wiki/Secant_method
            x(n) = (x(n-2)*y(n-1)-x(n-1)*y(n-2))/(y(n-1)-y(n-2));

            invoke(mcad,'SetVariable','PeakCurrent',x(n));
            invoke(mcad,'DoMagneticCalculation');
            [~, y(n)] = invoke(mcad,'GetVariable','OnLoadDQTorque');
            y(n) = y(n) - Torque_target;

            %[x y y+Torque_target]
            iterate = abs(y(n)) > tol * Torque_target;
            if (n > 6) && iterate
                % Should have converged by now, break
                iterate = 0;
                err = -1;
            end
        end
       
    end
    invoke(mcad,'SetVariable','MagneticThermalCoupling',3);
    invoke(mcad,'SetVariable','TorqueCalculation','True');
    Iq = x(n);
end 

