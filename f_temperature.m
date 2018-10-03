function z = f_temperature(v,k,mcad)
% Function returns motor constant
%   Detailed explanation goes here

    % Unpack variables
    tooth_width = v(1);
    slot_depth = v(2);
    %bore = v(3);
    %Idens = v(3);
    % Unpack constants
    mtype = cell2mat(k(1));
    Idens = cell2mat(k(2));
    % boundaries??
    
    invoke(mcad,'SetVariable','RMSCurrentDensity',Idens);
    invoke(mcad,'SetVariable','Tooth_Width',tooth_width);
    invoke(mcad,'SetVariable','Slot_Depth',slot_depth);
    if strcmp(mtype,'OR')
        invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/10);
    else
        invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/5);
    end
    
    err = invoke(mcad,'DoMagneticThermalCalculation');
    if err ~= -1
        [~, temperature.windingmax] = invoke(mcad,'GetVariable','T_[Winding_Max]');
        disp(sprintf('width=%.2f, depth =%.2f, Temperature=%.1fC, Idens=%.1f\n',tooth_width,slot_depth,temperature.windingmax,Idens));
        z = temperature.windingmax;
    else
        disp(sprintf('Failed torque calculation, err=%d,Tooth width=%.2f, Slot depth =%.2f\n',err,tooth_width,slot_depth));
        z = NaN;
    end
end

