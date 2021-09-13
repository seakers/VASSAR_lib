function design = ADCS_design(reqs)
%% Disturbance torques
Iy          = reqs.Iyy;
Iz          = reqs.Izz;
h           = reqs.Altitude;
theta       = reqs.MaxPointing;
As          = reqs.SurfaceArea;
q           = reqs.Reflectance;
i           = reqs.MaxSolarAngle;
cps_cg      = reqs.OffsetCPsolar;
cpa_cg      = reqs.OffsetCPaero;
D           = reqs.ResidualDipole;
Cd          = reqs.DragCoefficient;
V           = reqs.Velocity;
rho         = reqs.Density;
initConstants;
P = 2*pi/sqrt(3.986e14/(6378000+800000)^3);
%% Call internal functions
R = 1000*(RE/1000+h);
[Tg] = GGDisturbanceTorque (Iy, Iz, R, theta);
[Ta] = AeroDisturbanceTorque (Cd,As,R,cpa_cg);
[Tsp] = SPDisturbanceTorque (As, q, i, cps_cg);
[Tm] = MFDisturbanceTorque (D,R);
Tsp = Tsp.*ones(size(Tg));
T = [Tg;Tsp;Tm;Ta];
torque = max(T);

momentum  = (1/sqrt(2)).*torque.*P/4;
omega   = h./Iz;

design.RW_Mass = 1.5*momentum.^0.6;
design.RW_Power = 200*torque;

end