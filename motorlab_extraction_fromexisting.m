filename = 'C:\Users\eexjb5\Dropbox\Uni\PhD\Matlab\MotorDesign\MotorCAD_MATLAB_optimisationtest_slot_Idens_toothgeom_18s_16p_301117.mot';
% Motorlab, get parameters
mcad = actxserver('MotorCAD.AppAutomation');
invoke(mcad, 'LoadFromFile', filename);
invoke(mcad,'DoMagneticThermalCalculation');
invoke(mcad, 'SetMotorLABContext')
invoke(mcad, 'SetVariable', 'CalcTypeCuLoss_MotorLAB', 2);  % DC+AC(FEA) copper losses
invoke(mcad, 'SetVariable', 'CalcTypeIronLoss_MotorLAB', 3);  % DC+AC(FEA) copper losses
invoke(mcad, 'SetVariable', 'CalcTypeMagLoss_MotorLAB', 3);  % DC+AC(FEA) copper losses
maxcurrent = 1000;
maxspeed = 11e3;
invoke(mcad, 'SetVariable', 'Imin_MotorLAB', maxcurrent*0.1);
invoke(mcad, 'SetVariable', 'Imax_MotorLAB', maxcurrent);
invoke(mcad, 'SetVariable', 'Iinc_MotorLAB', 10);
invoke(mcad, 'SetVariable', 'MaxModelCurrent_MotorLAB', maxcurrent);
invoke(mcad, 'SetVariable', 'ModelBuildSpeed_MotorLAB', maxspeed);
%invoke(mcad, 'SetVariable', 'MaxModelSpeed_MotorLAB', maxspeed); % doesn't exist

invoke(mcad, 'SetVariable', 'SpeedMin_MotorLAB', maxspeed*0.1);
invoke(mcad, 'SetVariable', 'SpeedMax_MotorLAB', maxspeed);
invoke(mcad, 'SetVariable', 'MaxSpeedTherm_MotorLAB', maxspeed);
invoke(mcad, 'SetVariable', 'IM_SpeedMax_MotorLAB', maxspeed);
invoke(mcad, 'SetVariable', 'IM_MaxSpeedTherm_MotorLAB', maxspeed);

invoke(mcad, 'SetVariable', 'BuildLossModel_MotorLAB',1);
invoke(mcad, 'SetVariable', 'BuildSatModel_MotorLAB',1);
%%
invoke(mcad, 'BuildModel_Lab')
invoke(mcad, 'CalculateMagnetic_Lab')
%%
%motor = motorlab_exp_to_python(motor, sprintf('%ds%dp_%dkgMr\\MotorLAB_elecdata.mat',motor.slots,motor.poles,Mr_target),1);
motor = motorlab_exp_to_python(motor, 'MotorLAB_elecdata_301117.mat',1);

fprintf('R=%.2fmOhm, krpm1=%f, krpm2=%.8f\n',motor.Rs*1e3, motor.k_rpm(2), motor.k_rpm(3));

motor.m = 25.9;
motor.J = 0.0327;
%motor.N = 11; 
%motor.poles = 14;
%motor.L_core = 999;

motor.manufacturer = 'import';
disp(motor)


%file = '/home/jpb/Dropbox/Uni/PyCharmProjects/BikeSim/data_import/MotorLAB_export.mat';
file = 'C:\Users\eexjb5\Dropbox\Uni\PyCharmProjects\bike-sim\data_import\confidential\MotorLAB_export_301117.mat';
disp(file)

clearvars -except motor file Mr_target
% clear -x motor file
save('-v7',file)