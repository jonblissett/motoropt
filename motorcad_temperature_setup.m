invoke(mcad,'SetVariable','MagneticThermalMaxError',0.25);

invoke(mcad,'SetVariable','ProximityLossModel',1);
invoke(mcad,'SetVariable','ACLosses_IncludeBundleEffect',0);
%invoke(mcad,'SetVariable','RadialFlowVisualisation',0);

% Set materials
%invoke(mcad,'SetVariable','Insulation_Thickness',0.1);
invoke(mcad,'SetVariable','Liner_Thickness',0.2);
%invoke(mcad,'SetComponentMaterial','Wire Ins. [Active]','LordEpoxy');  %
%THIS WAS THE WIRE OOPS
invoke(mcad,'SetComponentMaterial','Impreg. [Active]','LordEpoxy');
invoke(mcad,'SetComponentMaterial','Potting [Front Endcap]','LordEpoxy');
invoke(mcad,'SetComponentMaterial','Potting [Rear Endcap]','LordEpoxy');

%invoke(mcad,'SetComponentMaterial','Slot Liner','Polyimide (PI)');%'TCP300_thermalpad'
invoke(mcad,'SetComponentMaterial','Shaft [Active]','Aluminium_7075');


invoke(mcad,'SetVariable','EWdg_Cavity',1);


invoke(mcad,'ShowThermalContext');
% Set cooling parameters
invoke(mcad,'SetVariable','AxialSliceDefinition',1);
invoke(mcad,'SetVariable','Housing_Water_Jacket',1);
invoke(mcad,'SetVariable','Shaft_Spiral_groove',1);
invoke(mcad,'SetVariable','ShaftSG_ShaftHoleCooling',1);
invoke(mcad,'SetVariable','WJ_Fluid_Volume_Flow_Rate', 0.000167);
invoke(mcad,'SetVariable','WJ_Parallel_Paths',3);

invoke(mcad,'SetVariable','Shaft_Groove_Fluid_Inlet_Temperature',25);
invoke(mcad,'SetVariable','Shaft_Groove_Fluid_Volume_Flow_Rate',0.05);
invoke(mcad,'SetVariable','HousingWJEndcapDuctType',2);
invoke(mcad,'SetVariable','WJ_Fluid_Inlet_Temperature',60);

invoke(mcad,'SetFluid','ShaftSGFluid','Air');
%invoke(mcad,'SetVariable','Shaft_Groove_Fluid_Thermal_Conductivity',0.02568);
%invoke(mcad,'SetVariable','Shaft_Groove_Fluid_Density',1.204);
%invoke(mcad,'SetVariable','Shaft_Groove_Fluid_Specific_Heat',1005.7);
%invoke(mcad,'SetVariable','Shaft_Groove_Fluid_Kinematic_Viscosity',1.502);

invoke(mcad,'SetFluid','HousingWJFluid','Water');
%invoke(mcad,'SetVariable','WJ_Fluid_Thermal_Conductivity',0.65);
%invoke(mcad,'SetVariable','WJ_Fluid_Density',983.2);
%invoke(mcad,'SetVariable','WJ_Fluid_Specific_Heat',4184);
%invoke(mcad,'SetVariable','WJ_Fluid_Kinematic_Viscosity',4.75e-7);

invoke(mcad,'SetVariable','StatorIronLossBuildFactor',2);
invoke(mcad,'SetVariable','RotorIronLossBuildFactor',2);
