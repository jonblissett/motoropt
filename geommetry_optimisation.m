% Let's maximise the motor constant, km

%mtype = 'OR';
mtype = 'IR';

%Npo = [14 16 22 28 38 42];
%Nsl = [12 18 18 24 42 36];

rpm = 8000; Vdc = 650; Idens = 12;
N = 8; layers = 1; throw = 1; pp = 2; Kfill = 0.55; % winding  
Np = 14;
Ns = 12;

if strcmp(mtype,'OR')
    bores = 190:5:210;
else
    %bores = 130:5:170;
    %bores = 150:2:166;
    bore = 160;
end

run motorcad_geometry_setup.m
invoke(mcad,'SetVariable','BackEMFCalculation','False');
invoke(mcad,'SetVariable','TorqueCalculation','True');
%invoke(mcad,  'DisableErrorMessages', true);
invoke(mcad,'SetVariable','TorqueNumberCycles',0.5);

if strcmp(mtype,'OR')
    tooth_width = 0.8 * magnet.arc/180*pi/Np*bore/2;
    slot_depth = tooth_width;
else
    tooth_width = 0.8 * magnet.arc/180*pi/Np*bore/2;
    slot_depth = (dia.statorlam-dia.statorbore)/2-tooth_width*0.67;% back iron 2/3 tooth width    
end

k = cell(2,1);                  % some constants - cell array for differing types
k(1) = {mtype};
k(2) = {Idens};
fun = @(v) -1*f_km(v,k,mcad);   % wrapper function

v0 = [tooth_width; slot_depth];
%v0 = [15.44; 17.49];
%v0 = [15.41; 17.48];

%options = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-2,'TolX',1e-2);
options = optimset('Display','iter-detailed','PlotFcns',@optimplotfval,'TolFun',1e-2,'TolX',2e-1);
[x, fval, exitflag, output] = fminsearch(fun,v0,options);

clearvars mcad
fname = ['test_slot_Idens_toothgeom_' num2str(Ns) 's_' num2str(Np) 'p_' num2str(dia.statorbore) 'mmbore'];
save(fname)
        
disp(x)
