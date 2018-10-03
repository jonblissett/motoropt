% Let's minimise the stator winding temperature 
% winding temp = f(tooth_width,slot_depth,Idense) while Torque > mintorque

%mtype = 'OR';
mtype = 'IR';

%Npo = [14 16 22 28 38 42];
%Nsl = [12 18 18 24 42 36];

rpm = 9000; Vdc = 650;  Idens = 20;
throw = 1; Kfill = 0.56; % winding  

Ipk = 800;
Np = 16;%16;%14;%16
Ns = 18;%18;%12;%18
N = 8;%8; %8
pp = 2;%2
layers = 1;%1

mintorque = 300;
gear = 83/18*375/mintorque;
Mr_target = 30;

I = Ipk;

if strcmp(mtype,'OR')
    bores = 190:5:210;
else
    %bores = 130:5:170;
    %bores = 150:2:166;
    %bore = 160;
    tooth_pitch = 0.5;  % tooth_width = tooth_pitch*pi*bore/Ns 
    yoke_ratio = 0.3;  % slot depth = (dia.statorlam-bore)/2*(1-yoke_ratio)
    bore_ratio = 0.7;
    I_ratio = 600/Ipk;
end

run motorcad_geometry_setup
run motorcad_temperature_setup
run motorcad_geometry_shaftandaxial_setup

run motorcad_set_build_factor
%%
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

v0 = [tooth_pitch; yoke_ratio; bore_ratio];   % initial conditions (NOT USED FOR GENETIC)

options = gaoptimset('Display','diagnose','PlotFcns',{@gaplotgenealogy,@gaplotscores,@gaplotselection,@gaplotbestindiv},'PopulationSize',30,'Generations',30);

nonlcon = @(v) f_torque_constraint(v,k,mcad);   % wrapper for constraint function
A = [];
b = [];
Aeq = [];
beq = [];
% [tooth_width, slot_depth, bore]
% for back iron = half tooth width: slot_depth = 0.5*((dia.statorlam-bore)-tooth_width)
lb = [0.3, 0.18, 0.74];%0.69];% Idens*0.5];  % boundary conditions
ub = [0.5, 0.26, 0.8];%0.83];% 25];
%[x, fval, exitflag, output] =
%patternsearch(fun,v0,A,b,Aeq,beq,lb,ub,nonlcon,options);

[x, fval, exitflag, output, population, scores] = ga(fun,numel(lb),A,b,Aeq,beq,lb,ub,[],options);
 

%clearvars mcad
fname = ['test_slot_Idens_toothgeom_' num2str(Ns) 's_' num2str(Np) 'p_' num2str(dia.statorbore) 'mmbore'];
save(fname)
        
%disp(x)

%system('python pythonfile.py')
%[status,cmdout] = system(command,'-echo')

load cacheFT
figure
plot3(cache.tooth_pitch,cache.yoke_ratio,cache.temp,'+')
figure
plot3(cache.tooth_pitch,cache.yoke_ratio,cache.Ivar,'+')