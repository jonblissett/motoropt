invoke(mcad,'AvoidImmediateUpdate',0);
invoke(mcad,'ShowThermalContext');

invoke(mcad,'SetVariable','BPM_Rotor',0);

invoke(mcad,'SetVariable','Magnetization',3);
invoke(mcad,'SetVariable','Magnet_Arc_[ED]',180);

invoke(mcad,'ShowMagneticContext');
invoke(mcad,'AvoidImmediateUpdate',1);