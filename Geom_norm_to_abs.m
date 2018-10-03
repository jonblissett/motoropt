function [ tooth_width, slot_depth, bore] = Geom_norm_to_abs(v,lam,Ns)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%[ tooth_width, slot_depth, bore] = Geom_norm_to_abs(x0,210,Ns)
        % Unpack variables
    tooth_pitch = v(1); % tooth_width = tooth_pitch*pi*bore/Ns
    yoke_ratio = v(2); % slot depth = (dia.statorlam-bore)/2*(1-yoke_ratio)
    I_ratio = v(3);
    bore_ratio = v(4);
    
    % Unpack constants
   
    bore = lam * bore_ratio;
    tooth_width = tooth_pitch*pi*bore/Ns;
    slot_depth = (lam-bore)/2*(1-yoke_ratio);
    
end

