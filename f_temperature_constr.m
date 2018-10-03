function z = f_temperature_constr(v,k,mcad)
% Function returns motor constant
%   Detailed explanation goes here
    
    % Unpack variables
    tooth_width = v(1);
    slot_depth = v(2);
    %bore = v(3);
    Ivar = v(3);
    % Unpack constants
    mtype = cell2mat(k(1));
    I = cell2mat(k(2));
    mintorque = cell2mat(k(3));
    % boundaries??
    
    load cache
    if numel(v) == 2
        z = cache.temp(and(ismember(cache.width,tooth_width),ismember(cache.depth,slot_depth)));
    end
    if numel(v) == 3
        z = cache.temp(and(and(ismember(cache.width,tooth_width),ismember(cache.depth,slot_depth)),ismember(cache.Ivar,Ivar)));
    end
    if numel(z) > 1
        printf('ERROR, multiple entries for x in cache')
    end
    if isempty(z)
        %if get 'CurrentDefinition' ...
        %invoke(mcad,'SetVariable','RMSCurrentDensity',I);
        if numel(v) > 2
            invoke(mcad,'SetVariable','PeakCurrent',Ivar);
        else
            invoke(mcad,'SetVariable','PeakCurrent',I);
        end
        invoke(mcad,'SetVariable','Tooth_Width',tooth_width);
        invoke(mcad,'SetVariable','Slot_Depth',slot_depth);
        SetBoreAndShaft(mcad,bore,mtype);
        if strcmp(mtype,'OR')
            invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/10);
        else
            invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/5);
        end

        err = invoke(mcad,'DoMagneticThermalCalculation');
        if err ~= -1
            [~, temperature.windingmax] = invoke(mcad,'GetVariable','T_[Winding_Max]');
            [To, ~, ~, L] = GetMCADgeneral(mcad);
            Km = To./(L.stator.^0.5);   % Nm/W^0.5 motor constant
            if To > mintorque
                fprintf('Cache mis, Temp = %.1f, T = %.1f Nm, Stator Losses = %d, AC Loss pc = %.1f%%, Km=%.2f, width=%.6f, depth =%.6f, Ipk =%d\n',temperature.windingmax,To,L.stator,L.AC/L.stator*100,Km,tooth_width,slot_depth,Ivar);
                z = temperature.windingmax;
            else
                fprintf('Cache mis, Torque of %.1f too low, Tooth width=%.6f, Slot depth =%.6f, Ipk=%d\n',To,tooth_width,slot_depth,Ivar);
                z = NaN;
            end
        else
            fprintf('Cache mis, Failed torque calculation, err=%d,Tooth width=%.6f, Slot depth =%.6f\n',err,tooth_width,slot_depth);
            z = NaN;
            Km = NaN;
            To = NaN;
            L.stator = NaN;
            L.AC = NaN;
        end
        cache.width(end+1) = v(1);
        cache.depth(end+1) = v(2);
        cache.temp(end+1) = z;
        cache.km(end+1) = Km;
        cache.torque(end+1) = To;
        cache.Lsta(end+1) = L.stator;
        cache.Lac(end+1) = L.AC;
        cache.I(end+1) = I;
        cache.Ivar(end+1) = Ivar;
        save cache.mat cache
    else
        fprintf('Cache hit, Tooth width=%.6f, Slot depth =%.6f, Temp %.1f\n',tooth_width,slot_depth,z);
    end
end

