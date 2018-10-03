function [m, Mr, J] = SetMCADmass(mcad, Mr_target, N, r)
% Adjusts core length for mass referred to wheel to equal target within tol
    invoke(mcad,'SetVariable','BackEMFCalculation','False');
    invoke(mcad,'SetVariable','TorqueCalculation','False');
    invoke(mcad,'SetVariable','MagneticThermalCoupling',0);
    
    invoke(mcad,'DoMagneticCalculation');   % else inertia isn't valid
    
    invoke(mcad,'ShowThermalContext');
    invoke(mcad,'DoWeightCalculation');
    [~, mi] = invoke(mcad,'GetVariable','Weight_Calc_Total');
    [~, Ji.total] = invoke(mcad,'GetVariable','TotalInertia');
    [~, Ji.rotor] = invoke(mcad,'GetVariable','RotorInertia');
    [~, Ji.shaft] = invoke(mcad,'GetVariable','ShaftInertia');
    
    %Jr = N^2*J.total;
    Mri = mi + N^2*Ji.total/(r^2);    
    
    [~, Lcorei] = invoke(mcad,'GetVariable','Magnet_Length');
    [~, Lmotor] = invoke(mcad,'GetVariable','Motor_Length');
    Ladd = Lmotor - Lcorei;
    
    invoke(mcad,'SetVariable','Motor_Length',Ladd+0.1);
    invoke(mcad,'SetVariable','Stator_Lam_Length',0.1);
    invoke(mcad,'SetVariable','Rotor_Lam_Length',0.1);
    invoke(mcad,'SetVariable','Magnet_Length',0.1);
    
    
    invoke(mcad,'DoMagneticCalculation');   % else inertia isn't valid
    %invoke(mcad,'ShowThermalContext');
    invoke(mcad,'DoWeightCalculation');
    [~, m0] = invoke(mcad,'GetVariable','Weight_Calc_Total');
    [~, J0.total] = invoke(mcad,'GetVariable','TotalInertia');
    [~, J0.rotor] = invoke(mcad,'GetVariable','RotorInertia');
    [~, J0.shaft] = invoke(mcad,'GetVariable','ShaftInertia');
    
    %dM = mi - m0;
    %dJ = Ji.total - J0.total;
    Mr0 = m0 + N^2*J0.total/(r^2);
    
    dMr = Mr0 - Mri;
    dL = - Lcorei - 0.1;
    
    Lnew = dL/dMr * (Mr_target-Mr0);
    
    invoke(mcad,'SetVariable','Motor_Length',Ladd+Lnew);
    invoke(mcad,'SetVariable','Stator_Lam_Length',Lnew);
    invoke(mcad,'SetVariable','Rotor_Lam_Length',Lnew);
    invoke(mcad,'SetVariable','Magnet_Length',Lnew);
    
    invoke(mcad,'DoMagneticCalculation');   % else inertia isn't valid
    %invoke(mcad,'ShowThermalContext');
    invoke(mcad,'DoWeightCalculation');
    [~, m] = invoke(mcad,'GetVariable','Weight_Calc_Total');
    [~, J.total] = invoke(mcad,'GetVariable','TotalInertia');
    [~, J.rotor] = invoke(mcad,'GetVariable','RotorInertia');
    [~, J.shaft] = invoke(mcad,'GetVariable','ShaftInertia');
    
    Mr = m + N^2*J.total/(r^2);
    
    invoke(mcad,'ShowMagneticContext');
    
    invoke(mcad,'SetVariable','MagneticThermalCoupling',3);
    invoke(mcad,'SetVariable','TorqueCalculation','True');
    
end

