% Let's minimise the stator winding temperature 
% winding temp = f(tooth_width,slot_depth,Idense) while Torque > mintorque

sprintf('Should I quit this and use octave to more easily link with sim?')

%mtype = 'OR';
mtype = 'IR';

%Npo = [14 16 22 28 38 42];
%Nsl = [12 18 18 24 42 36];

rpm = 8000; Vdc = 650; Ipk = 600; Idens = 20;
N = 8; layers = 1; throw = 1; pp = 2; Kfill = 0.56; % winding  
Np = 14;
Ns = 12;

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
invoke(mcad, 'SetVariable', 'MessageDisplayState',1)    % 2 for overwrite, 1 for crucial
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
k(2) = {I};
k(3) = {mintorque};
k(4) = {Ipk};
fun = @(v) f_temperature(v,k,mcad);   % wrapper for function to minimise

%v0 = [tooth_width; slot_depth];%; Idens];
%v0 = [15.44; 17.49];
%v0 = [16.32; 18.29; Idens];
%v0 = [14; 16];  % values from old optimisation
%v0 = [20.27; 18.4]; % values from new optimisation, first go
v0 =[20.92; 18.45];

options = psoptimset
%options = optimoptions('patternsearch','MeshTolerance',0.05)
options = optimoptions('fmincon','Display','iter-detailed','PlotFcns',@optimplotx,'TolFun',0.1,'TolX',1e-1,'FinDiffRelStep',5e-2);
%options = optimset('Display','iter-detailed','PlotFcns',@optimplotx,'TolFun',1,'TolX',1e-1);
%,'Algorithm','sqp','Diagnostics','on',,@optimplotfval,'Algorithm','quasi-newton',
% maybe I should specify current, instead of current density, for same flux?
nonlcon = @(v) f_torque_constraint(v,k,mcad);   % wrapper for constraint function
A = [];
b = [];
Aeq = [];
beq = [];
lb = [tooth_width*0.6; (dia.statorlam-bore)/4];% Idens*0.5];  % boundary conditions
ub = [tooth_width*1.6; (dia.statorlam-bore)/2*0.9];% 25];
%[x, fval, exitflag, output] = fmincon(fun,v0,A,b,Aeq,beq,lb,ub,nonlcon,options);
gs = GlobalSearch('NumStageOnePoints',10);
problem =         createOptimProblem('fmincon','objective', fun, 'x0', v0, ...
        'Aineq', A, 'bineq', b, 'Aeq', Aeq, 'beq', beq, 'lb', lb, ...
        'ub', ub, 'nonlcon', nonlcon, 'options', options);

[xmin,fmin,flag,output,allmins] = run(gs,problem);    
    
    
%clearvars mcad
fname = ['test_slot_Idens_toothgeom_' num2str(Ns) 's_' num2str(Np) 'p_' num2str(dia.statorbore) 'mmbore'];
save(fname)
        
%disp(x)

%system('python pythonfile.py')
%[status,cmdout] = system(command,'-echo')
