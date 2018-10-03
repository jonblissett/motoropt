function [c,ceq] = f_torque_constraint(v,k,mcad)
% fmincon optimizes such that c(x) ? 0 and ceq(x) = 0

    % Unpack variables
    tooth_width = v(1);
    slot_depth = v(2);
    % Unpack constants
    mtype = cell2mat(k(1));
    Idens = cell2mat(k(2));
    mintorque = cell2mat(k(3));
    
    % Check if motorcad results are for current value of v()
    [~, v0(1)] = invoke(mcad,'GetVariable','Tooth_Width');
    [~, v0(2)] = invoke(mcad,'GetVariable','Slot_Depth');
    
    if isequal(v,v0)    
        [To, ~, ~, L] = GetMCADgeneral(mcad);
        err = 0;
    else
        invoke(mcad,'SetVariable','RMSCurrentDensity',Idens);
        invoke(mcad,'SetVariable','Tooth_Width',tooth_width);
        invoke(mcad,'SetVariable','Slot_Depth',slot_depth);
        if strcmp(mtype,'OR')
            invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/10);
        else
            invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/5);
        end
        [To, ~, ~, L] = GetMCADgeneral(mcad);
        err = invoke(mcad,'DoMagneticThermalCalculation');
    end
   
    Km = To./(L.stator.^0.5);   % Nm/W^0.5 motor constant
    
    if err ~= -1
        [~, temperature.windingmax] = invoke(mcad,'GetVariable','T_[Winding_Max]');    
        fprintf('T = %.1f, Stator Losses = %d, AC Loss pc = %.1f%%, Km=%.2f, width=%.7f, depth =%.7f,\n',To,L.stator,L.AC/L.stator*100,Km,tooth_width,slot_depth);
        c = mintorque-To;
    else
        fprintf('Failed torque calculation, err=%d,Tooth width=%.2f, Slot depth =%.2f\n',err,tooth_width,slot_depth);
        c = NaN;
    end
    
    ceq = [];
