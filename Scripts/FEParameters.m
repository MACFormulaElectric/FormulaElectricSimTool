clc; clear;

%% Simulation Settings
Sim.TimeStep = 0.001;

%% Import Drivecycles
DC = input('Select the drivecycle you want to run: ', 's');
Laps = input('Number of laps: ');
DriveCycle.Cycle.FSGE2010 = xlsread('Drivecycles.xlsx', 1);
DriveCycle.Cycle.FSGE2012 = xlsread('Drivecycles.xlsx', 2);
DriveCycle.Cycle.FSGE2012_90 = xlsread('Drivecycles.xlsx', 2);

% First Lap
DriveCycle.Speed = [DriveCycle.Cycle.(DC)(:,2) DriveCycle.Cycle.(DC)(:,1)/3.6];
DriveCycle.Tf = DriveCycle.Speed(end, 1);

% Second Lap to n Laps
if (Laps > 1)
    for i = 2:Laps
        % Concatenate the last lap data to this lap
        DriveCycle.Speed = [DriveCycle.Speed;[(DriveCycle.Tf+DriveCycle.Cycle.(DC)(:,2)) DriveCycle.Cycle.(DC)(:,1)/3.6]];
        DriveCycle.Tf = DriveCycle.Speed(end, 1);
    end
end

DriveCycle.Vi = DriveCycle.Speed(1,2);
DriveCycle.Tf = roundn(DriveCycle.Tf, -1);

%% Vehicle Parameters
% General
RPM2Rad = 0.104719755;
Inch2m = 0.0254;
Motor.MinSpd = 1E-7;
g = 9.81;

% Environment
Env.Air.p = 1.225; %kg/m3
Env.AmbTemp = 20 + 273.15;      %K
Env.NaturalConvection.K = 10;    %W/M2K

% Driver
Driver.Kd= 0;
Driver.Kp = 20; 
Driver.Ki= 1;
Driver.Mass = 70;             %kg, slowing us down. go on a diet man...

% Vehicle Dynamics
Veh.Mass.m = 200;
Veh.Mass.static = Veh.Mass.m + Driver.Mass;
Veh.Mass.inertial = Veh.Mass.m * 1.02 + Driver.Mass;      %kg - take into account rotational masses, dummy

Veh.Whl.r = 10*Inch2m/2;      %m:
Veh.Whl.SidewallH = 18*Inch2m/2 - Veh.Whl.r;      %m

Veh.Tires.rr.Spd = [0 60 120] * 1/3.6;
Veh.Tires.rr.rr = [0.01 0.0125 0.015];
Veh.Tires.Ks = 1.5;

Veh.FrntTrk = 1.270;          %m
Veh.RearTrk = 1.2192;         %m

Veh.WhlBase = 1.525;          %m
Veh.CGofWhlBase = 0.4112;     %dec
Veh.CGHeight = 0.229;         %m

Veh.Drag.Cd = 0.3;            % ratio dummy
Veh.Air.p = Env.Air.p;
Veh.SA = 1.4;                   %m2 dummy

% Brakes
Brake.MaxForce = 4000*2;       %N(Scaling for BPP Driver)
Brake.FntBias = 0.6;
Brake.RearBias = 1-Brake.FntBias;

% Aero
Aero.LiftK = 0.5;
Aero.FrntLiftK = 0.24;
Aero.RearLiftK = 0.26;


% Motor
Motor.PeakTime = 1.24;      % s
Motor.PeakTrq =  21;        % Nm
Motor.ContTrq = 13.8;       % Nm

Motor.MaxTrq.Trq = [21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.34	21.07	19.66	18.04	16.15	0	0];
Motor.MaxTrq.Spd = [0	1000	2000	3000	4000	5000	6000	7000	8000	9000	10000	11000	12000	13000	14000	15000	16000	17000	18000	19000	20000	20001] * RPM2Rad; 
Motor.VoltageK = 18.8 * sqrt(2) * RPM2Rad;      % rad/(V*s)

Motor.Efficiency.Eff = [64.37	71.33	73.64	74.7	75.43	76.57	77	77.08	77.56	78.14;
58.42	70.48	77.57	80.4	82.01	83.92	85.16	85.44	85.97	86.5;
44.94	60.81	73.35	78.82	81.94	85.43	88.2	88.88	89.71	90.44;
35.59	51.9	67.02	74.26	78.54	83.42	87.58	88.65	89.84	90.86;
29.14	44.78	61.01	69.41	74.57	80.62	85.93	87.34	88.86	90.16;
24.17	38.71	55.22	64.39	70.24	77.3	83.73	85.48	87.37	88.98;
20.41	33.76	50.04	59.65	65.99	73.88	81.33	83.42	85.66	87.59;
17.31	29.4	45.1	54.87	61.55	70.1	78.56	80.97	83.56	85.81;
14.82	25.75	40.67	50.41	57.28	66.34	75.7	78.4	81.34	83.91;
12.81	22.67	36.72	46.3	53.25	62.67	72.77	75.75	79.02	81.91;
11.17	20.05	33.21	42.51	49.44	59.09	69.82	73.06	76.63	79.83] * 0.01;

Motor.Efficiency.Spd = [500 1000 2000 3000 4000 6000 10000 12000 15000 19000] * RPM2Rad;    %Rad/s
Motor.Efficiency.Trq = [1.3 2.7 5.4 7.9 10.4 12.5 14.4 16 17.4 18.5 19.6];                  %Nm

Motor.GR = 13; 

% Battery
Battery.Cell.VoltOC.Voltage= [2.8 3.2 3.4 3.5 3.6 3.7 3.85 4.2];
Battery.Cell.VoltOC.SoC = [-0.02 0 0.05 0.2 0.4 0.6 0.8 1];
Battery.Cell.NumParallel = 1;
Battery.Cell.NumSeries = 146;
%Battery.Cell.VoltOC.SoC = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
%Battery.Cell.VoltOC.Voltage = [2.25 3.2 3.25 3.25 3.3 3.3 3.3 3.35 3.35 3.35 3.75];
Battery.Cell.Qfull = 13*3600;               %C
Battery.Cell.Qi = Battery.Cell.Qfull;
Battery.Cell.R = 5/1000;                    %Ohms
Battery.Cell.m = 0.155;         % kg
Battery.Cell.CrntLmt.Chrg = 15; %cRATE
Battery.Cell.CrntLmt.Dschrg = 3; %cRATE
Battery.Cell.c = 450;           % steel                           %W/KgC

Battery.SA = 1;                 % m2
Battery.m = Battery.Cell.NumParallel * Battery.Cell.NumSeries * Battery.Cell.m;         %                    %kg


