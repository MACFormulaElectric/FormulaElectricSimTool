clc; clear; 

%% Motor Parameters
RPM2Rad = 0.104719755;

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



%% Optimization

MtrSpd_Peak = 19000;
MtrSpd_int = 500;

MtrTrqTot_Peak = 2*21;
MtrTrqTot_int = 1;
MtrTrq_Peak = 21;
MtrTrq_int = 0.25; 

for i = 0:MtrSpd_Peak/MtrSpd_int
    MtrSpd = i*MtrSpd_int*RPM2Rad;
    
    % Avoid div by 0
    if (MtrSpd == 0)
        MtrSpd = 1E-7;
    end 
    
    for j = MtrTrqTot_int:MtrTrqTot_Peak/MtrTrqTot_int
        
        MtrTrqTot = j * MtrTrqTot_int;
        BestEff = 0.001;
        BestTrqFnt = -999;
        BestTrqRear = -999;
        
        for MtrTrqFnt = -MtrTrq_Peak:MtrTrq_int:MtrTrq_Peak
            for MtrTrqRear = -MtrTrq_Peak:MtrTrq_int:MtrTrq_Peak
                
                if (MtrTrqFnt + MtrTrqRear == MtrTrqTot)
                    EffFnt = max([interp2(Motor.Efficiency.Spd, Motor.Efficiency.Trq, Motor.Efficiency.Eff, MtrSpd, MtrTrqFnt) 0.01]);
                    EffRear = max([interp2(Motor.Efficiency.Spd, Motor.Efficiency.Trq, Motor.Efficiency.Eff, MtrSpd, MtrTrqRear) 0.01]);
                    
                    MtrPwrFnt = MtrSpd * MtrTrqFnt;
                    MtrPwrRear = MtrSpd * MtrTrqRear;
                    ElecPwrFnt = MtrPwrFnt / EffFnt;
                    ElecPwrRear = MtrPwrRear / EffRear;
                    
                    Eff = (MtrPwrFnt + MtrPwrRear) / (ElecPwrFnt + ElecPwrRear);
                    
                    if Eff >= BestEff 
                        BestEff = Eff;
                        BestTrqFnt = MtrTrqFnt;
                        BestTrqRear = MtrTrqRear;
                    end
                end
            end
        end
        TrqSplit.Trq(j+1) = MtrTrqTot;
        TrqSplit.FrontTrq(i+1,j+1) = BestTrqFnt;
        TrqSplit.RearTrq(i+1,j+1) = BestTrqRear;
        TrqSplit.Eff(i+1,j+1) = BestEff; 
        NormalSplit.Eff(i+1, j+1) = max([interp2(Motor.Efficiency.Spd, Motor.Efficiency.Trq, Motor.Efficiency.Eff, MtrSpd, MtrTrqTot) 0.01]);
        NormalSplit.Improvement = TrqSplit.Eff - NormalSplit.Eff; 
        
        
    end
    TrqSplit.Spd(i+1) = MtrSpd;
end

disp(mean(mean(NormalSplit.Improvement)));
                                      