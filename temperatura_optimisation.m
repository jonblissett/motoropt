% Let's minimise the stator winding temperature 
% winding temp = f(tooth_width,slot_depth,Idense) while Torque > mintorque

sprintf('Should I quit this and use octave to more easily link with sim?')

%mtype = 'OR';
mtype = 'IR';

%Npo = [14 16 22 28 38 42];
%Nsl = [12 18 18 24 42 36];

rpm = 8000; Vdc = 650; Idens = 12;
N = 8; layers = 1; throw = 1; pp = 2; Kfill = 0.6; % winding  
Np = 14;
Ns = 12;
mintorque = 200;

if strcmp(mtype,'OR')
    bores = 190:5:210;
else
    %bores = 130:5:170;
    %bores = 150:2:166;
    bore = 160;
end

run motorcad_geometry_setup.m
run motorcad_temperature_setup
run motorcad_geometry_shaftandaxial_setup.m
invoke(mcad,'SetVariable','BackEMFCalculation','False');
invoke(mcad,'SetVariable','TorqueCalculation','True');
invoke(mcad,'SetVariable','TorqueNumberCycles',0.5);

invoke(mcad,'SetVariable','MagneticThermalCoupling',3); % 3 = iterate to convergence
invoke(mcad,'DoMagneticThermalCalculation');            % Steady State Analysis

%invoke(mcad,'SetVariable','MagneticThermalCoupling',1); % 1 = losses -> thermal

invoke(mcad,  'DisableErrorMessages', true);
sprintf('WARNING: MOTORCAD ERROR MESSAGES DISABLED')

if strcmp(mtype,'OR')
    tooth_width = 0.8 * magnet.arc/180*pi/Np*bore/2;
    slot_depth = tooth_width;
else
    tooth_width = 0.8 * magnet.arc/180*pi/Np*bore/2;
    slot_depth = (dia.statorlam-dia.statorbore)/2-tooth_width*0.67;% back iron 2/3 tooth width    
end

k = cell(3,1);                  % some constants - cell array for differing types
k(1) = {mtype};
k(2) = {Idens};
k(3) = {mintorque};
fun = @(v) f_temperature(v,k,mcad);   % wrapper for function to minimise

v0 = [tooth_width; slot_depth];%; Idens];
%v0 = [15.44; 17.49];
%v0 = [16.32; 18.29; Idens];

%options = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-2,'TolX',1e-2);
options = optimset('Display','iter-detailed','PlotFcns',@optimplotfval,'TolFun',1e-2,'TolX',1e-3);
%,'Algorithm','sqp'
% maybe I should specify current, instead of current density, for same flux?
nonlcon = @(v) f_torque_constraint(v,k,mcad);   % wrapper for constraint function
A = [];
b = [];
Aeq = [];
beq = [];
lb = [tooth_width*0.5; slot_depth*0.5];% Idens*0.5];  % boundary conditions
ub = [tooth_width*2; slot_depth*1.5];% 25];
[x, fval, exitflag, output] = fmincon(fun,v0,A,b,Aeq,beq,lb,ub,nonlcon,options);

%clearvars mcad
fname = ['test_slot_Idens_toothgeom_' num2str(Ns) 's_' num2str(Np) 'p_' num2str(dia.statorbore) 'mmbore'];
save(fname)
        
disp(x)
