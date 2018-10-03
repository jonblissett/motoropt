function z = f_km(v,k,mcad)
% Function returns motor constant
%   Detailed explanation goes here
    
    % Unpack variables
    tooth_width = v(1);
    slot_depth = v(2);
    %bore = v(3);
    %I_dens = v(3);
    % Unpack constants
    mtype = cell2mat(k(1));
    Idens = cell2mat(k(2));
    mintorque = cell2mat(k(3));
    % boundaries??
    
    load cachek
    z = cache.km(and(ismember(cache.width,tooth_width),ismember(cache.depth,slot_depth)));
    if max(size(z)) > 1
        fprintf('ERROR, multiple entries for x in cache')
    end
    if isempty(z)
        invoke(mcad,'SetVariable','RMSCurrentDensity',Idens);
        invoke(mcad,'SetVariable','Tooth_Width',tooth_width);
        invoke(mcad,'SetVariable','Slot_Depth',slot_depth);
        if strcmp(mtype,'OR')
            invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/10);
        else
            invoke(mcad,'SetVariable','Slot_Corner_Radius',slot_depth/5);
        end
        invoke(mcad,'DoMagneticCalculation');             % Steady State Analysis
        [To, ~, ~, L] = GetMCADgeneral(mcad);

        Km = To./(L.stator.^0.5);   % Nm/W^0.5 motor constant
        %Lo(i,j) = L.stator;
        fprintf('Cache mis, T = %.1f, Tooth width=%.2f, Slot depth =%.2f, Km=%.3f, Total Stator Losses = %.2f, AC Loss pc = %.1f%%\n',To,tooth_width,slot_depth,Km,L.stator,L.AC/L.stator*100)
        z = Km;
        
        cache.width(end+1) = v(1);
        cache.depth(end+1) = v(2);
        cache.km(end+1) = z;
        cache.temp(end+1) = 0;
        save cachek cache
    else
        fprintf('Cache hit, Tooth width=%.6f, Slot depth =%.6f, Km %.1f\n',tooth_width,slot_depth,z);
    end
end

