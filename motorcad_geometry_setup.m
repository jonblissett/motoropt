dia.housing = 235+5;
dia.statorlam = 210+5;
dia.statorbore = bore_ratio * dia.statorlam;%bore;%130;   % ~ Airgap diameter, started with 150mm
dia.shaft = dia.statorbore*0.3;
%tooth.width = 0.5*dia.statorbore*pi/Ns; % set to 1/2 slot pitch

tooth.width = tooth_pitch*pi*dia.statorbore/Ns;
if strcmp(mtype,'OR')
    slot.depth = tooth.width;
    slot.corner_radius = slot.depth/10;
else
    %slot.depth = (dia.statorlam-dia.statorbore-tooth.width)/2; % back iron 1/2 tooth width
    slot.depth = (dia.statorlam-dia.statorbore)/2*(1-yoke_ratio);
    slot.corner_radius = slot.depth/5;
end

slot.opening = 0.22*dia.statorbore*pi/Ns; % wild guess


airgap = dia.statorlam/100;
length.stator = 125;%148;%125    % core length
length.motor = length.stator + 55;
length.magnet = length.stator;
length.rotor = length.stator;
magnet.h = 6;
magnet.segments = 8;
magnet.axseg = round(length.stator/(1.5*magnet.h));
magnet.arc = 160;   % degrees

sprintf('Add rotor sleeve')

        fname = ['test_slot_Idens_toothgeom_' num2str(Ns) 's_' num2str(Np) 'p_' num2str(dia.statorbore) 'mmbore_' mtype];
        MotorCAD_File_Name = fname;

        mcad = actxserver('MotorCAD.AppAutomation');    % Open Motor-CAD
        %invoke(mcad,'LoadFromFile','C:\Users\eexjb5\Dropbox\Uni\PhD\Matlab\MotorDesign\MotorCAD\vaco_stator_N42.mot');

        %pause so can draw cross-section before changing values
        pause(1)

        if strcmp(mtype,'OR')
            invoke(mcad,'SetVariable','Motor_Type',3);
            invoke(mcad,'SetVariable','Armature_Diameter',dia.statorbore);
            invoke(mcad,'SetVariable','Magnet_Thickness',magnet.h);
            invoke(mcad,'SetVariable','Housing_Thickness',3);
            invoke(mcad,'SetVariable','Back_Iron_Thickness',dia.housing-dia.statorbore-2*(magnet.h+3));
        else
            invoke(mcad,'SetVariable','Housing_Dia',dia.housing);
            invoke(mcad,'SetVariable','Stator_Lam_Dia',dia.statorlam);
            invoke(mcad,'SetVariable','Stator_Bore',dia.statorbore);
            invoke(mcad,'SetVariable','Magnet_Thickness',magnet.h);
        end
        % Set variables in Motor-CAD
        %invoke(mcad,'ShowThermalContext');
        invoke(mcad,'SetComponentMaterial','Magnet','VACODYM_633HR'); %'N42SH');% 'Recoma 32'
        invoke(mcad,'SetComponentMaterial','Stator Lam (Back Iron)','VX48 VACSTACK 0.05');%'JFE_10JNEX900');
        invoke(mcad,'SetComponentMaterial','Stator Lam (Tooth)','VX48 VACSTACK 0.05');%'JFE_10JNEX900');%'VACOFLUX 50 0.20 strip'
        invoke(mcad,'SetComponentMaterial','Rotor Lam (Back Iron)','VX48 VACSTACK 0.05');%'JFE_10JNEX900');
        %invoke(mcad,'SetComponentMaterial','Winding [Active]','Aluminium (1060)');
        %invoke(mcad,'ShowMagneticContext');
        
        invoke(mcad,'SetVariable','Slot_Number',Ns);          
        invoke(mcad,'SetVariable','Pole_Number',Np);
        invoke(mcad,'SetVariable','Tooth_Width',tooth.width);
        invoke(mcad,'SetVariable','Slot_Depth',slot.depth);
        invoke(mcad,'SetVariable','Slot_Opening',slot.opening);
        invoke(mcad,'SetVariable','CircumferentialSegments',magnet.segments);
        invoke(mcad,'SetVariable','AxialSegments',magnet.axseg);
        invoke(mcad,'SetVariable','Airgap',airgap);
        invoke(mcad,'SetVariable','Motor_Length',length.motor);
        invoke(mcad,'SetVariable','Stator_Lam_Length',length.stator);
        invoke(mcad,'SetVariable','Rotor_Lam_Length',length.rotor);
        invoke(mcad,'SetVariable','Magnet_Length',length.magnet);
        invoke(mcad,'SetVariable','Magnet_Arc_[ED]',magnet.arc);
        invoke(mcad,'SetVariable','Shaft_Dia',dia.shaft);

        invoke(mcad,'SetVariable','StatorConductor_Temperature',160);%127
        invoke(mcad,'SetVariable','StatorLam_Temperature',146);%103
        invoke(mcad,'SetVariable','Magnet_Temperature',45);%178
        invoke(mcad,'SetVariable','RotorLam_Temperature',32);%175
        invoke(mcad,'SetVariable','Shaft_Temperature',26);%172

        % operating point
        invoke(mcad,'SetVariable','Shaft_Speed_[RPM]',rpm);
        invoke(mcad,'SetVariable','DCBusVoltage',Vdc);
        % current density
        % current density value
        if I == Idens
			invoke(mcad,'SetVariable','CurrentDefinition',2);   % set RMS current density
			invoke(mcad,'SetVariable','RMSCurrentDensity',Idens);
		else
			invoke(mcad,'SetVariable','CurrentDefinition',0);   % set Peak current
			invoke(mcad,'SetVariable','PeakCurrent',Ipk);
		end

        % winding
        invoke(mcad,'SetVariable','MagTurnsConductor',N);
        invoke(mcad,'SetVariable','Winding_Layers',layers);
        invoke(mcad,'SetVariable','MagThrow',throw); 
        invoke(mcad,'SetVariable','ParallelPaths',pp); 
        invoke(mcad,'SetVariable','NumberStrandsHand',50/N);
        invoke(mcad,'SetVariable','Wedge_Model',1);
        
        invoke(mcad,'SetVariable','Slot_Corner_Radius', slot.corner_radius);

        invoke(mcad,'SetVariable','Wdg_Definition', 2);
        invoke(mcad,'SetVariable','RequestedGrossSlotFillFactor',Kfill);

        %invoke(mcad,'ShowMagneticContext');
        invoke(mcad,'SetVariable','Housing_Type',11);

        invoke(mcad,'SetVariable','CoggingTorqueCalculation','False');
        invoke(mcad,'SetVariable','TorqueSpeedCalculation','False');
        invoke(mcad,'SetVariable','TorqueCalculation','False');
        invoke(mcad,'SetVariable','DemagnetizationCalc','False');

        % Declare folder locations
        %FilePath = 'C:\Users\eexjb5\Dropbox\Uni\PhD\Matlab\MotorDesign\MotorCAD\';
        FilePath = pwd;
        FileName = strcat(FilePath,MotorCAD_File_Name,'_temp.mot');
        res = invoke(mcad,'SaveToFile',FileName);
        %break