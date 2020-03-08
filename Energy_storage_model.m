clc

%% Importing data from Entso-e and open-power-system-data.org 
% Column 1: Total load in Netherlands in MW as published on ENTSO-E power statistics Platform
% Column 2: Total load in Netherlands in MW as published on ENTSO-E Transparency Platform
% Column 3: Day-ahead load forecast in Netherlands in MW as published on ENTSO-E Transparency Platform
% Column 4: Solar generation in the Netherlands (MW)
% Column 5: Wind generation off-shore in the Netherlands (MW)
% COlumn 6: Wind generation on-shore in the Netherlands (MW)
load('Dutch_hourly data_2018');  
load('Dutch_hourly data');
load('P_load17');
load('P_gen17');

%% creating individual vectors

Data_in=Dutchhourlydata2018;
Load_PS=Data_in(:,1);
Load_TP=Data_in(:,2);
Load_forecast=Data_in(:,3);
Generation_solar=Data_in(:,4);
Generation_offshore=Data_in(:,5);
Generation_onshore=Data_in(:,6);

%% Other year

% % Comparing load data: 
% figure; hold on
% plot(Load_PS)
% plot(Load_TP)

%% Data inspection
% Weird 10x higher peak in these 90 days)
for i=1804:1896
    Dutchhourlydata(i,3)="Nan";
end

% Slow unexplainable reduction in load, probably due to lack of data
Dutchhourlydata(36385:37945,:)=[ ];

%Load data selection: Data is similar, Power Statistics seems more complete
P_load18=Load_PS;

%% Demand scaling
E_2018=sum(P_load18)/10^6;       %TWh in 2018
E_2030=135;                      %TWh in 2030 (energiecijfers.info)
P_load30_m=P_load18*(E_2030/E_2018);
P_load30=timeseries(P_load30_m);
save('P_load30.mat','P_load30','-v7.3')

%% Demand scaling for 2017
E_2017=sum(P_load17)/10^6;       %TWh in 2018
E_2030=135;                      %TWh in 2030 (energiecijfers.info)
P_load30_17=P_load17*(E_2030/E_2017);
P_load30_17=timeseries(P_load30_17);
save('P_load30_17.mat','P_load30_17','-v7.3')


%% Wind generation scaling
P_gen30_m=Generation_offshore*(1/0.957);  %Installed capacity: 4 GW in IJmuiden ver, 957 MW in 2018. 
P_gen30=timeseries(P_gen30_m);
save('P_gen30.mat','P_gen30','-v7.3')

%% Wind generation scaling 2017
P_gen30_17=P_gen17*(1/0.957);  %Installed capacity: 4 GW in IJmuiden ver, 957 MW in 2018. 
P_gen30_17=timeseries(P_gen30_m);
save('P_gen30_17.mat','P_gen30_17','-v7.3')

%% Mismatch 

Mismatch=P_gen30_m-P_load30_m/48;


%% Battery scaling
%plot(Daymismatch);

% Daily mismatches
for i=24:8760;
    Daymismatch(i-23)=sum(Mismatch(i-23:i));
end
min(Daymismatch);
Daymismatch_abs=abs(Daymismatch);
Mean_Day=mean(Daymismatch_abs);
Max_Day=max(Daymismatch_abs);
Mean_Day
Max_Day

% Week mismatch
for i=168:8760;
    Weekmismatch(i-167)=sum(Mismatch(i-167:i));
end
min(Weekmismatch);
Weekmismatch_abs=abs(Weekmismatch);
Mean_Week=mean(Weekmismatch_abs);
Max_Week=max(Weekmismatch_abs);

Mean_Week
Max_Week

% 4-hour mismatch
for i=4:8760;
    Hoursmismatch(i-3)=sum(Mismatch(i-3:i));
end
min(Hoursmismatch);
Hoursmismatch_abs=abs(Hoursmismatch);
Mean_Hours=mean(Hoursmismatch_abs);
Max_Hours=max(Hoursmismatch_abs);

Mean_Hours
Max_Hours
