function [T, P, B, Loss] = GetMCADgeneral(mcad)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [~, T] = invoke(mcad,'GetVariable','OnLoadDQTorque');
    [~, P] = invoke(mcad,'GetVariable','ElectromagneticPower');

    [~, B.ag] = invoke(mcad,'GetVariable','BMax_Airgap');
    [~, B.tooth] = invoke(mcad,'GetVariable','BMax_StatorTooth');
    [~, B.statorback] = invoke(mcad,'GetVariable','BMax_StatorBackIron');
    [~, B.rotorback] = invoke(mcad,'GetVariable','BMax_RotorBackIron');

    % [~, Loss.statorback] = invoke(mcad,'GetVariable','StatorBackIronLoss_Total');
    % [~, Loss.statortooth] = invoke(mcad,'GetVariable','StatorToothLoss_Total');
    % [~, Loss.magOC] = invoke(mcad,'GetVariable','MagnetLoss_OC');
    % [~, Loss.magtotal] = invoke(mcad,'GetVariable','MagnetLoss');
    % [~, Loss.copper] = invoke(mcad,'GetVariable','ConductorLoss');

    [~, Loss.statorback] = invoke(mcad,'GetVariable','StatorBackIronLoss_Total_Static');
    [~, Loss.statortooth] = invoke(mcad,'GetVariable','StatorToothLoss_Total_Static');
    [~, Loss.mag] = invoke(mcad,'GetVariable','MagnetLoss');
    [~, Loss.copper] = invoke(mcad,'GetVariable','ConductorLoss');
    [~, Loss.AC] = invoke(mcad,'GetVariable','ACConductorLoss_MagneticMethod_Total');

    Loss.stator = Loss.statorback + Loss.statortooth + Loss.copper + Loss.AC;

end

