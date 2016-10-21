%% Post-Processing
SimResults.Motor.LossFL= mean(MotorLossesFL);
SimResults.Motor.LossFR = mean(MotorLossesFR);
SimResults.Motor.LossRL= mean(MotorLossesRL);
SimResults.Motor.LossRR = mean(MotorLossesRR);

SimResults.Motor.EffFL= mean(MotorEffFL);
SimResults.Motor.EffFR = mean(MotorEffFR);
SimResults.Motor.EffRL= mean(MotorEffRL);
SimResults.Motor.EffRR = mean(MotorEffRR);

SimResults.Motor.TrqFL= mean(abs(MotorTrqFL));
SimResults.Motor.TrqFR = mean(abs(MotorTrqFR));
SimResults.Motor.TrqRL= mean(abs(MotorTrqRL));
SimResults.Motor.TrqRR = mean(abs(MotorTrqRR));

disp('Average Motor Torque = (Nm)');
disp(SimResults.Motor.TrqFL);
disp(SimResults.Motor.TrqFR);
disp(SimResults.Motor.TrqRL);
disp(SimResults.Motor.TrqRR);

disp('Average Motor Heat Generation = (W)');
disp(SimResults.Motor.LossFL);
disp(SimResults.Motor.LossFR);
disp(SimResults.Motor.LossRL);
disp(SimResults.Motor.LossRR);

disp('Average Motor Efficiency = (%)');
disp(SimResults.Motor.EffFL);
disp(SimResults.Motor.EffFR);
disp(SimResults.Motor.EffRL);
disp(SimResults.Motor.EffRR);

disp('Average Brake Heat = (W)');
disp(mean(QBrakeFL));
disp(mean(QBrakeFR));
disp(mean(QBrakeRL));
disp(mean(QBrakeRR));

disp('Final BatterySOC = (%)');
disp(BatterySOC(end));

disp('Final Distance (km)');
disp(yout(end,4) / 1000);