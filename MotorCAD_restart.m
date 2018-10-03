function [error, mcad_new] = MotorCAD_restart(mcad)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    error = invoke(mcad,'SaveToFile','temp_reboot');
    sprintf('Rebooting MotorCAD');
    pause(3);
    %invoke(mcad,'Quit');
    Quit(mcad);
    delete(mcad);
    %clear mcad
    mcad_new = actxserver('MotorCAD.AppAutomation');    % Open Motor-CAD
    invoke(mcad_new,'LoadFromFile','temp_reboot');
    
    invoke(mcad_new, 'DisableErrorMessages', true);
    invoke(mcad_new, 'SetVariable', 'MessageDisplayState',1);    % 2 for overwrite, 1 for crucial
    pause(3);
    fprintf('WARNING: MOTORCAD ERROR MESSAGES DISABLED\n');
end

