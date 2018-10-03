% Copyright (C) 2017 
% 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% -*- texinfo -*- 
% @deftypefn {} {@var{retval} =} motorlab_exp_to_python (@var{input1}, @var{input2})
%
% @seealso{}
% @end deftypefn

% Author:  <jpb@l540-arch>
% Created: 2017-05-23

function [motor] = motorlab_exp_to_python (motor, motorlab_file,enable_plotting)
  Is = []; Iq = []; Speed = []; Electromagnetic_Torque = [];
  load(motorlab_file);
  xdata = Is(1,:);
  ydata = Speed(:,1);
  zdata = Total_Loss(:,:);
  %surf(Is(1,:),Speed(:,1),TotalLoss)

  Rs_guess = mean(mean(Copper_Loss./(Is.^2)));

  F = @(x,xd,yd) (x(1).*xd.^2 + x(2).*yd + 1e-5*x(3).*yd.^2);
  [X,Y] = meshgrid(xdata,ydata);

  Fsumsquares = @(x) sum(sum((F(x,X,Y) - zdata).^2));
  x0 = [Rs_guess; 0.01; 1;];

  [x, ~, ~, ~] = fminunc(Fsumsquares,x0);%,options);

  %format long
  %fprintf('R=%.2fmOhm, krpm1=%f, krpm2=%.8f\n',x(1)*1e3,x(2),x(3)/1e5);
  motor.Rs = x(1);
  %motor.krpm1 = x(2);
  %motor.krpm2 = x(3)/1e5;
  motor.k_rpm = [0, x(2), x(3)/1e5];
  
  torque_per_amp = Electromagnetic_Torque(1,2) / Iq(1,2);
  
  torque_no_sat = Iq(1,:)*torque_per_amp;
  torque_diff_pct = (torque_no_sat - Electromagnetic_Torque(1,:))./Electromagnetic_Torque(1,:);
  
  linear_upto_index = 1+ sum(torque_diff_pct < 0.03);

  if enable_plotting
    figure
    surf(Is(1,:),Speed(:,1),Total_Loss)
    hold on
    mesh(xdata,ydata,F(x,X,Y))
    hold off
    xlabel('Is (A)')
    ylabel('Speed (RPM)')
    zlabel('Total losses (W)')
    figure
    %plot(Iq(1:(length(Iq)-1):end,:),Electromagnetic_Torque(1,:),(0 Iq(1,end)),(0 Iq(1,end)*torque_per_amp))
    plot(Iq(1,:),Electromagnetic_Torque(1,:),Iq(1,:),torque_no_sat,'-+',Iq(1,linear_upto_index),torque_no_sat(linear_upto_index),'o')
  end
  
  mid = round(length(Iq)/2);
  motor.i_rms_con = Iq(1,linear_upto_index)/sqrt(2);
  motor.i_rms_pk = Iq(1,end)/sqrt(2);
  motor.T_con = Electromagnetic_Torque(1,linear_upto_index);
  motor.T_pk = Electromagnetic_Torque(1,end);
  motor.Ld = Ld(mid,mid)*1e-3;
  motor.Lq = Lq(mid,mid)*1e-3;
  
  %motor.co = zeros(1,4);
  [a, b, c, d] = motor_saturation_coeff(motor.T_con / motor.i_rms_con, motor.i_rms_pk, motor.T_pk, motor.i_rms_con, motor.T_con);
  motor.co(1) = a;
  motor.co(2) = b;
  motor.co(3) = c;
  motor.co(4) = d;
  torque_cubic = motor.co(1) * Iq(1,:).^ 3 + motor.co(2) * Iq(1,:).^ 2 + motor.co(3) * Iq(1,:) + motor.co(4);
  
  X = Iq(1,:);
  Y = Electromagnetic_Torque(1,:);
  xp = polyfit(X,Y,3)';
  x0 = xp(1:3);

  Fcubic = @(P,xi) (P(1).*xi.^3 + P(2).*xi.^2 + P(3).*xi);
  %Fsumsquares = @(x) sum((Fcubic(x,X) - Y).^2);
  %x1 = fminunc(Fsumsquares,x0);
  x = lsqcurvefit(Fcubic,x0,X,Y);
  disp([xp(1:3) x])
  if enable_plotting
    figure
    plot(Iq(1,:), [Electromagnetic_Torque(1,:)', torque_cubic', Fcubic(x,X)'])
    xlabel('Iq (A)')
    ylabel('Torque (Nm)')
    legend('FEA','Simple cubic', 'Least squares cubic','Location','NorthWest')
  end
  motor.co = [x; 0];
end
