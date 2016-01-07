%Calculate descriptive statistics about a location's rainfall data

rain = csvread('NATT_Darwin.dat');

lngth = length(rain);
rain = rain(1:floor(lngth/365)*365); %make sure rain data is for an integer number of years
lngth = length(rain);
yrs = lngth/365;
rain = reshape(rain,365,yrs);

MAP = mean(sum(rain));

%let's give a description of the seasonality

%plot mean rainfall by day
% figure
% bar(mean(rain,2))

%Day 110 is April 20. Day 293 is Oct. 20.
DryMean = mean(sum(rain(110:292,:)));
DryStd = std(sum(rain(110:292,:)));
WetMean = mean(sum(cat(1,rain(1:109,:),rain(293:end,:))));
WetStd = std(sum(cat(1,rain(1:109,:),rain(293:end,:))));

disp(['MAP = ', num2str(MAP)])
disp(['Avg. Precip. between April 20 and Oct. 19 = ', num2str(DryMean)])
disp(['Standard deviation = ', num2str(DryStd)])
disp(['Avg. Precip. between Oct. 20 and April 19 = ', num2str(WetMean)])
disp(['Standard deviation = ', num2str(WetStd)])

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

[MaxDryP,MaxDryIndx] = max(sum(rain(110:292,:)));
disp(['The wetest April 20 - Oct. 19 (dry) season had ', num2str(MaxDryP), ' mm.'])
% figure
% bar(rain(110:292,MaxDryIndx))
[MinWetP,MinWetIndx] = min(sum(cat(1,rain(1:109,:),rain(293:end,:))));
disp(['The driest Oct. 20 - April 19 (wet) season had ', num2str(MinWetP), ' mm.'])
% figure
% bar(cat(1,rain(1:109,MinWetIndx),rain(293:end,MinWetIndx)))