invoke(mcad,'ShowMagneticContext');

SetBoreAndShaft(mcad, bore_ratio, mtype);
%shaft_dia = bore-2*(airgap+2.4*magnet.h);
%invoke(mcad,'SetVariable','Shaft_Dia',shaft_dia);
%invoke(mcad,'SetVariable','Shaft_Dia_[F]',10*floor(shaft_dia/10));
%invoke(mcad,'SetVariable','Shaft_Dia_[R]',10*floor(shaft_dia/10));
%invoke(mcad,'SetVariable','Shaft_Hole_Diameter',10*floor(shaft_dia/10)-10);

%invoke(mcad,'SetVariable','Bearing_Width_[F]',12);
%invoke(mcad,'SetVariable','Bearing_Width_[R]',12);
%invoke(mcad,'SetVariable','Bearing_Dia_[F]',10*floor(shaft_dia/10)+20);
%invoke(mcad,'SetVariable','Bearing_Dia_[R]',10*floor(shaft_dia/10)+20);

invoke(mcad,'SetVariable','EWdg_Overhang_[F]',20);
invoke(mcad,'SetVariable','EWdg_Overhang_[R]',20);
invoke(mcad,'SetVariable','Wdg_Add_[Outer_F]',3);
invoke(mcad,'SetVariable','Wdg_Add_[Outer_R]',3);

%invoke(mcad,'SetVariable','Endcap_Length_[F]',10);
%invoke(mcad,'SetVariable','Endcap_Length_[R]',10);

invoke(mcad,'SetVariable','Plate_Thickness',10);
invoke(mcad,'SetVariable','Flange_Dia',180);

