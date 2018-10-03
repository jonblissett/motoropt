function z = f_temperature_constr_ratio(v,k,mcad)
% Function returns motor constant
%   Detailed explanation goes here
    
    % Unpack variables
    tooth_pitch = v(1); % tooth_width = tooth_pitch*pi*bore/Ns
    yoke_ratio = v(2); % slot depth = (dia.statorlam-bore)/2*(1-yoke_ratio)
    I_ratio = v(3);
    bore_ratio = v(4);
    % Unpack constants
    mtype = cell2mat(k(1));
    I = cell2mat(k(2));     % Current value (A) if constant
    mintorque = cell2mat(k(3));
    Ilim = cell2mat(k(4));  % Drive current limit (for I_ratio)
    
    Ivar = I_ratio * Ilim;
    
    message = '';
    
    load cache
    if numel(v) == 2
        cache_index = ismember(cache.tooth_pitch,tooth_pitch) & ismember(cache.yoke_ratio,yoke_ratio);
    end
    if numel(v) == 3
        cache_index = ismember(cache.tooth_pitch,tooth_pitch) & ismember(cache.yoke_ratio,yoke_ratio)  & ismember(cache.I_ratio,I_ratio);
    end
    if numel(v) == 4
        cache_index = ismember(cache.tooth_pitch,tooth_pitch) & ismember(cache.yoke_ratio,yoke_ratio)  & ismember(cache.I_ratio,I_ratio) & ismember(cache.bore_ratio,bore_ratio);
    end
    z = cache.temp(cache_index);
    if numel(z) > 1
        printf('ERROR, multiple entries for x in cache')
    end
    if isempty(z)
        message = strcat(message,'Cache MISS, ');
        %if get 'CurrentDefinition' ...
        %invoke(mcad,'SetVariable','RMSCurrentDensity',I);
        if numel(v) > 2
            invoke(mcad,'SetVariable','PeakCurrent',Ivar);
        else
            invoke(mcad,'SetVariable','PeakCurrent',I);
        end
        
        % Get more variables
        [~, lam] = invoke(mcad,'GetVariable','Stator_Lam_Dia');
        [~, Ns] = invoke(mcad,'GetVariable','Slot_Number');
        %bore = 0.1*round(lam * bore_ratio * 10);    % Round bore to nearest 0.1mm
        [~, bore] = SetBoreAndShaft(mcad,bore_ratio,mtype);
        tooth_width = tooth_pitch*pi*bore/Ns;
        slot_depth = (lam-bore)/2*(1-yoke_ratio);
        
        invoke(mcad,'SetVariable','Tooth_Width',tooth_width);
        invoke(mcad,'SetVariable','Slot_Depth',slot_depth);

        if strcmp(mtype,'OR')
            invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/10);
        else
            invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/5);
        end
        
        [~, contemp] = invoke(mcad,'GetVariable','StatorConductor_Temperature');
        if contemp > 200
            invoke(mcad,'SetVariable','StatorConductor_Temperature',160);%127
            invoke(mcad,'SetVariable','StatorLam_Temperature',100);%103
            invoke(mcad,'SetVariable','Magnet_Temperature',50);%178
            invoke(mcad,'SetVariable','RotorLam_Temperature',37);%175
            invoke(mcad,'SetVariable','Shaft_Temperature',26);%172
        end

        err = invoke(mcad,'DoMagneticThermalCalculation');
        if err ~= -1
            message = strcat(message,'PASS, ');
            [~, temperature.windingmax] = invoke(mcad,'GetVariable','T_[Winding_Max]');
            [To, ~, ~, L] = GetMCADgeneral(mcad);
            Km = To./(L.stator.^0.5);   % Nm/W^0.5 motor constant
            if To > mintorque
                %fprintf('Cache mis, Temp = %.1f, T = %.1f Nm, Stator Losses = %d, AC Loss pc = %.1f%%, Km=%.2f, width=%.6f, depth =%.6f, Ipk =%d\n',temperature.windingmax,To,L.stator,L.AC/L.stator*100,Km,tooth_width,slot_depth,Ivar);
                z = temperature.windingmax;
            else
                %fprintf('Cache mis, Torque of %.1f too low, Tooth width=%.6f, Slot depth =%.6f, Ipk=%d\n',To,tooth_width,slot_depth,Ivar);
                z = NaN;
            end
        else
            % Failed torque calculation
            message = strcat(message,'FAIL, ');
            temperature.windingmax = NaN;
            To = NaN;
            L.stator = NaN;
            L.AC = NaN;
            Km = NaN;
            z = NaN;
        end
        % Update cache
        cache.tooth_pitch(end+1) = v(1);
        cache.yoke_ratio(end+1) = v(2);
        cache.I_ratio(end+1) = v(3);
        cache.bore_ratio(end+1) = v(4);
        cache.temp(end+1) = z;
        cache.km(end+1) = Km;
        cache.torque(end+1) = To;
        cache.Lsta(end+1) = L.stator;
        cache.Lac(end+1) = L.AC;
        cache.Ivar(end+1) = Ivar;
        save cache.mat cache
    else
        message = strcat(message,'Cache HIT , ');
        message = strcat(message,'PASS, ');
        % Load from cache
        temperature.windingmax = cache.temp(cache_index);
        To = cache.torque(cache_index);
        L.stator = cache.Lsta(cache_index);
        L.AC = cache.Lac(cache_index);
        Km = cache.km(cache_index);
    end
    message = strcat(message,sprintf('tp = %.3f, yr = %.3f, Ir = %.3f, Br = %.3f, ', tooth_pitch, yoke_ratio, I_ratio, bore_ratio));
    message = strcat(message,sprintf(' Temp = %.1f, T = %.1f Nm, Stator Losses = %d, AC Loss pc = %.1f, Km=%.2f',temperature.windingmax,To,L.stator,L.AC/L.stator*100,Km));
    fprintf(message);
    fprintf('\n');
end

