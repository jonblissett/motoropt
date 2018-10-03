function [m, J] = GetMCADmass(mcad,docalc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    invoke(mcad,'SetVariable','BackEMFCalculation','False');
    invoke(mcad,'SetVariable','TorqueCalculation','False');
    invoke(mcad,'SetVariable','MagneticThermalCoupling',0);
    
    if docalc
        invoke(mcad,'DoMagneticCalculation');   % else inertia isn't valid
    end
    
    
    invoke(mcad,'ShowThermalContext');
    invoke(mcad,'DoWeightCalculation');
    [~, m] = invoke(mcad,'GetVariable','Weight_Calc_Total');
    [~, J.total] = invoke(mcad,'GetVariable','TotalInertia');
    [~, J.rotor] = invoke(mcad,'GetVariable','RotorInertia');
    [~, J.shaft] = invoke(mcad,'GetVariable','ShaftInertia');
        
    invoke(mcad,'ShowMagneticContext');
    
    invoke(mcad,'SetVariable','MagneticThermalCoupling',3);
    invoke(mcad,'SetVariable','TorqueCalculation','True');

end

