% passport, current sensor, tooth
load 18s16p_tempVSmass
t = 17; % minutes

E = StatorLoss.*(t/60);
rho = 180;

madd = E./rho;
% extra drag from more cooling
plot(Temp, m+madd,'+')
xlabel('Winding hotspot temperature (°C)')
ylabel('Motor + extra battery mass (kg)')