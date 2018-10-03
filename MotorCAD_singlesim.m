function [ temperature, motor ] = MotorCAD_singlesim(motor, Ipk, Mr_target, v, filename)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% Let's minimise the stator winding temperature 
% winding temp = f(tooth_width,slot_depth,Idense) while Torque > mintorque

    %mtype = 'OR';
    mtype = 'IR';

    %Npo = [14 16 22 28 38 42];
    %Nsl = [12 18 18 24 42 36];

    Vdc = 650;  Idens = 20;
    throw = 1; Kfill = 0.56; % winding  

    %Ipk = 800;
    %Np = 16;%10;%14;%16
    %Ns = 18;%12;%12;%18
    Np = motor.poles;
    Ns = motor.slots;
    N = 8;%9;%8; %5
    pp = 2;%2
    layers = 1;%1

    %tp = 0.578; yr = 0.227; Ir = 0.762; Br = 0.730;

    %tp=0.493;yr=0.231;Ir=0.64;Br=0.745;
    %tp = 0.598; yr = 0.239; Ir = 2.275; Br = 0.756;
    %v = [tp; yr; Br];   % initial conditions (NOT USED FOR GENETIC)

    tooth_pitch = v(1);
    yoke_ratio = v(2);
    bore_ratio = v(3);
    
    mintorque = motor.mintorque;
    rpm = 8000*250/mintorque; 
    gear = 83/18*250/mintorque;
    %Mr_target = 25;
    I = Ipk;

    run motorcad_geometry_setup
    run motorcad_temperature_setup
    run motorcad_geometry_shaftandaxial_setup

    invoke(mcad,'AvoidImmediateUpdate',1)

    invoke(mcad,'SetVariable','BackEMFCalculation','False');
    %invoke(mcad,'SetVariable','BackEMFNumberCycles',0.5);
    invoke(mcad,'SetVariable','TorqueCalculation','True');
    invoke(mcad,'SetVariable','TorqueNumberCycles',1);  % Don't use <1 as this stops AC loss calculation
    invoke(mcad,'SetVariable','TorquePointsPerCycle',Np);
    invoke(mcad,'SetVariable','ProximityLossesEnabled',1);

    invoke(mcad,'SetVariable','MagneticThermalCoupling',3); % 3 = iterate to convergence
    %invoke(mcad,'DoMagneticThermalCalculation');            % Steady State Analysis

    %invoke(mcad,'SetVariable','MagneticThermalCoupling',1); % 1 = losses -> thermal

    invoke(mcad, 'DisableErrorMessages', true);
    invoke(mcad, 'SetVariable', 'MessageDisplayState',1);    % 2 for overwrite, 1 for crucial
    fprintf('WARNING: MOTORCAD ERROR MESSAGES DISABLED\n');

    k = cell(6,1);                  % some constants - cell array for differing types
    k(1) = {mtype};
    k(2) = {I};
    k(3) = {mintorque};
    k(4) = {Ipk};
    k(5) = {Mr_target};
    k(6) = {gear};
    fun = @(v) f_temperature_constr_ratio_fixTMr(v,k,mcad);   % wrapper for function to minimise

    v0 = v;   % initial conditions (NOT USED FOR GENETIC)


    temperature = fun(v0);
    
    
    invoke(mcad,'ShowThermalContext');
    invoke(mcad,'DoWeightCalculation');
    [~, motor.m] = invoke(mcad,'GetVariable','Weight_Calc_Total');
    [~, motor.J] = invoke(mcad,'GetVariable','TotalInertia');
    [~, motor.N] = invoke(mcad,'GetVariable','StatorTurnsPerCoil');
    [~, motor.L_core] = invoke(mcad,'GetVariable','Stator_Lam_Length');
    
    invoke(mcad, 'SaveToFile', filename)
    invoke(mcad, 'Quit')

end

