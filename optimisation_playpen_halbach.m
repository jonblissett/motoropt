
% Let's minimise the stator winding temperature 
% winding temp = f(tooth_width,slot_depth,Idense) while Torque > mintorque

%mtype = 'OR';
mtype = 'IR';

%Npo = [14 16 22 28 38 42];
%Nsl = [12 18 18 24 42 36];

Vdc = 650;  Idens = 20;
throw = 1; Kfill = 0.56; % winding  

Ipk = 800;
Np = 16;%10;%14;%16
Ns = 18;%12;%12;%18
N = 8;%9;%8; %5
pp = 2;%2
layers = 1;%1

%tp = 0.578; yr = 0.227; Ir = 0.762; Br = 0.730;

%tp=0.493;yr=0.231;Ir=0.64;Br=0.745+rand*1e-4;
%tp = 0.457; yr = 0.277; Ir = 0.596; Br = 0.763;	% run 2, JNEX
%tp = 0.500; yr = 0.246; Ir = 0.602; Br = 0.758; % run 1, JNEX
%tp = 0.441; yr = 0.256; Ir = 0.607; Br = 0.769; % JNEX, 9000rpm
%tp = 0.498; yr = 0.256; Ir = 0.598; Br = 0.769+rand*1e-4; % JNEX, 9000rpm
%tp = 0.493; yr = 0.246; Ir = 0.587; Br = 0.767+rand*1e-4;

%tp = 0.39; yr = 0.228; Ir = 0.592; Br = 0.769+rand*1e-4;
tp = 0.367; yr = 0.218; Ir = 0.597; Br = 0.765+rand*1e-4;

%tp = 0.598; yr = 0.239; Ir = 2.275; Br = 0.756;

bore_ratio = Br;
tooth_pitch = tp;
yoke_ratio = yr;

mintorque = 300;
rpm = 9000*300/mintorque; 
gear = 83/18*300/mintorque;
Mr_target = 30;
I = Ipk;

run motorcad_geometry_setup
run motorcad_temperature_setup
run motorcad_geometry_shaftandaxial_setup
run motorcad_set_build_factor

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

k = cell(4,1);                  % some constants - cell array for differing types
k(1) = {mtype};
k(2) = {I};
k(3) = {mintorque};
k(4) = {Ipk};
k(5) = {Mr_target};
k(6) = {gear};
fun = @(v) f_temperature_constr_ratio_fixTMr(v,k,mcad);   % wrapper for function to minimise
%%

%load cacheFT
%tp = cache.tooth_pitch(152);
%yr = cache.yoke_ratio(152);
%br = cache.bore_ratio(152);
v0 = [tp; yr; Br];   % initial conditions (NOT USED FOR GENETIC)


fun(v0)


