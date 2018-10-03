% Let's minimise the stator winding temperature 
% winding temp = f(tooth_width,slot_depth,Idense) while Torque > mintorque

%mtype = 'OR';
mtype = 'IR';

%Npo = [14 16 22 28 38 42];
%Nsl = [12 18 18 24 42 36];

rpm = 8000; Vdc = 650;  Idens = 20;
layers = 1; throw = 1; Kfill = 0.56; % winding  

Ipk = 800;
Np = 10;%14;%16
Ns = 12;%12;%18
N = 9;%8; %5
pp = 1;%2
layers = 0;%1
boremin = 125;
boremax = 160;
%RE-RUN 1412 for SINGLE LAYER winding

mintorque = 250;
I = Ipk;

if strcmp(mtype,'OR')
    bores = 190:5:210;
else
    %bores = 130:5:170;
    %bores = 150:2:166;
    bore = 160;
end

run motorcad_geometry_setup
run motorcad_temperature_setup
run motorcad_geometry_shaftandaxial_setup
SetBoreAndShaft(mcad,bore);

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
fprintf('WARNING: MOTORCAD ERROR MESSAGES DISABLED\nTry aluminium wire??');

if strcmp(mtype,'OR')
    tooth_width = 0.8 * magnet.arc/180*pi/Np*bore/2;
    slot_depth = tooth_width;
else
    tooth_width = 0.8 * magnet.arc/180*pi/Np*bore/2;
    slot_depth = (dia.statorlam-dia.statorbore-tooth_width)/2;% back iron 1/2 tooth width
end

k = cell(4,1);                  % some constants - cell array for differing types
k(1) = {mtype};
k(2) = {I};
k(3) = {mintorque};
k(4) = {Ipk};
fun = @(v) f_temperature_constr(v,k,mcad);   % wrapper for function to minimise
%fun = @(v) -1*f_km(v,k,mcad);   % wrapper function

%v0 = [tooth_width; slot_depth];%; Idens];
%v0 = [15.44; 17.49];
%v0 = [16.32; 18.29; Idens];
%v0 = [14, 16];  % values from old optimisation
v0 = round([20.27; 18.4; Ipk; bore]); % values from new optimisation, first go
%from v0 of 20; 18 using MADSpositive found 20.425, 18.265


options = gaoptimset('Display','diagnose','PlotFcns',{@gaplotgenealogy,@gaplotscores,@gaplotselection,@gaplotbestindiv},'PopulationSize',40,'Generations',25);

nonlcon = @(v) f_torque_constraint(v,k,mcad);   % wrapper for constraint function
A = [];
b = [];
Aeq = [];
beq = [];
% [tooth_width, slot_depth, Ipk, bore]
% back iron = half tooth width: slot_depth = 0.5*((dia.statorlab-bore)-tooth_width)
lb = [0.5*pi/Np*bore, (dia.statorlam-bore)*0.35, Ipk*0.5, boremin];% Idens*0.5];  % boundary conditions
ub = [0.7*pi/Np*bore, (dia.statorlam-bore)/2*0.9, Ipk, boremax];% 25];
%[x, fval, exitflag, output] =
%patternsearch(fun,v0,A,b,Aeq,beq,lb,ub,nonlcon,options);
break
[x, fval, exitflag, output, population, scores] = ga(fun,numel(lb),A,b,Aeq,beq,lb,ub,[],options);
 

%clearvars mcad
fname = ['test_slot_Idens_toothgeom_' num2str(Ns) 's_' num2str(Np) 'p_' num2str(dia.statorbore) 'mmbore'];
save(fname)
        
%disp(x)

%system('python pythonfile.py')
%[status,cmdout] = system(command,'-echo')

load cache
figure
plot3(cache.width,cache.depth,cache.temp,'+')
figure
plot3(cache.width,cache.depth,cache.Ivar,'+')