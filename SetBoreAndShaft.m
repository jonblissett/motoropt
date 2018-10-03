function [ error, bore ] = SetBoreAndShaft(mcad, bore_ratio, mtype)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [~, lam] = invoke(mcad,'GetVariable','Stator_Lam_Dia');
    
    bore = 0.1*round(lam * bore_ratio * 10);    % Round bore to nearest 0.1mm
    
    %[~, b] = invoke(mcad,'GetVariable','Stator_Bore');
    %if b ~= bore
        [~, airgap] = invoke(mcad,'GetVariable','Airgap');
        [~, h] = invoke(mcad,'GetVariable','Magnet_Thickness');

        if strcmp(mtype,'IR')
            shaft_dia = bore-2*(airgap+2.4*h); % set magnet backiron to 10% more than magnet thickness

            invoke(mcad,'SetVariable','Stator_Bore',bore);

            invoke(mcad,'SetVariable','Shaft_Dia',shaft_dia);
            invoke(mcad,'SetVariable','Shaft_Dia_[F]',10*floor(shaft_dia/10));
            invoke(mcad,'SetVariable','Shaft_Dia_[R]',10*floor(shaft_dia/10));
            invoke(mcad,'SetVariable','Shaft_Hole_Diameter',10*floor(shaft_dia/10)-10);

            invoke(mcad,'SetVariable','Bearing_Width_[F]',12);
            invoke(mcad,'SetVariable','Bearing_Width_[R]',12);
            invoke(mcad,'SetVariable','Bearing_Dia_[F]',10*floor(shaft_dia/10)+20);
            invoke(mcad,'SetVariable','Bearing_Dia_[R]',10*floor(shaft_dia/10)+20);
            error = 0;
        else
            sprintf('ERROR, for bore setting %s not implemented',mtype)
            error = -1;
        end
    %else
    %    error = -2;  % Bore unchanged
    %end
end

