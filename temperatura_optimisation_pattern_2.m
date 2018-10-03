% Let's minimise the stator winding temperature 
% winding temp = f(tooth_width,slot_depth,Idense) while Torque > mintorque

%mtype = 'OR';
mtype = 'IR';

%Npo = [14 16 22 28 38 42];
%Nsl = [12 18 18 24 42 36];

rpm = 8000; Vdc = 650;  Idens = 20;
layers = 1; throw = 1; pp = 2; Kfill = 0.56; % winding  

Ipk = 800;
Np = 14;
Ns = 12;
N = 8; 

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
fun = @(v) f_temperature_constr(v,k,mcad);   % wrapper for function to minimise
%fun = @(v) -1*f_km(v,k,mcad);   % wrapper function

%v0 = [tooth_width; slot_depth];%; Idens];
%v0 = [15.44; 17.49];
%v0 = [16.32; 18.29; Idens];
%v0 = [14, 16];  % values from old optimisation
%v0 = round([20.92; 18.45]); % values from new optimisation, first go
%from v0 of 20; 18 using MADSpositive found 20.425, 18.265
v0 = round([13.8; 19; 600]); % values from new optimisation, first go


%options = psoptimset('TolFun',0.25,'Cache','on','CacheTol',1e-4,'TolMesh',0.01,'PlotFcns',@psplotbestf,'Display','diagnose');
%options = optimoptions('fmincon','Display','iter-detailed','PlotFcns',@optimplotx,'TolFun',0.1,'TolX',1e-1,'FinDiffRelStep',5e-2);
options = psoptimset('TolFun',1e-3,'Cache','off','PlotFcns',@psplotbestf,'Display','diagnose','MeshRotate','on','CompletePoll','off','PollMethod','MADSPositiveBasisNp1','MeshAccelerator','on');%'InitialMeshSize',4);
%options = optimset('Display','iter-detailed','PlotFcns',@optimplotx,'TolFun',1,'TolX',1e-1);
%,'Algorithm','sqp','Diagnostics','on',,@optimplotfval,'Algorithm','quasi-newton',
% maybe I should specify current, instead of current density, for same flux?
nonlcon = @(v) f_torque_constraint(v,k,mcad);   % wrapper for constraint function
A = [];
b = [];
Aeq = [];
beq = [];
lb = [0.4*pi/Np*bore, (dia.statorlam-bore)/4, Ipk*0.4];% Idens*0.5];  % boundary conditions
ub = [0.7*pi/Np*bore, (dia.statorlam-bore)/2*0.9, Ipk];% 25];
%lb = v0 - [2; 2; 200];
%ub = v0 + [2; 2; 200];
%[x, fval, exitflag, output] = patternsearch(fun,v0,A,b,Aeq,beq,lb,ub,nonlcon,options);
[x, fval, exitflag, output] = patternsearch(fun,v0,A,b,Aeq,beq,lb,ub,[],options);

%options = saoptimset('PlotFcns',{@saplotbestx, @saplotbestf, ...
%      @saplotx, @saplotf},'Display','diagnose','DisplayInterval',1);
%[x, fval, exitflag, output] = simulannealbnd(fun,v0,lb,ub,options);

%gs = GlobalSearch('NumStageOnePoints',10);
%problem =         createOptimProblem('patternsearch','objective', fun, 'x0', v0, ...
%        'Aineq', A, 'bineq', b, 'Aeq', Aeq, 'beq', beq, 'lb', lb, ...
%        'ub', ub, 'nonlcon', nonlcon, 'options', options);

%[xmin,fmin,flag,output,allmins] = run(gs,problem);    
    
    
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
