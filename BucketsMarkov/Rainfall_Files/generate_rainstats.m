%convert rain data into daily mean/varience for a one year period

rain = csvread('Sydney.dat'); %INPUT daily rainfall data, 365 days a year

lngth = length(rain);
rain = rain(1:floor(lngth/365)*365); %make sure rain data is for an integer number of years
lngth = length(rain);
yrs = lngth/365;
rain = reshape(rain,365,yrs);

rainmean = mean(rain,2);
rainstd = std(rain,0,2);

%find probability that it rains each day, and rainy day only stats
didrain = zeros(size(rain));
rainprob = zeros(365,1);
rainonlymean = zeros(365,1);
rainonlyvar = zeros(365,1);
k = zeros(365,1);
theta = zeros(365,1);
for dd=1:365,
    clearvars rainydays
    rainydays = 0;
    for ee=1:yrs,
        if rain(dd,ee)>0,
            didrain(dd,ee)=1;
            rainydays = [rainydays, rain(dd,ee)];
        end
    end
    rainprob(dd)=sum(didrain(dd,:))/yrs;
    if length(rainydays)==1,
        rainonlymean(dd) = 0;
        rainonlyvar(dd) = 0;
    else
        rainydays = rainydays(2:end);
        rainonlymean(dd) = mean(rainydays);
        rainonlyvar(dd) = var(rainydays);
    end
    
    %Calculate Gamma parameters from mean and variance
    if rainonlyvar(dd) == 0,
        k(dd) = 0;
        theta(dd) = 0;
        rainprob(dd) = 0; %here we lose single year rain events.
        %An alternative is to record these events and take a mean, applying
        %that rainfall if rain occurs on that day.
    else
        k(dd) = (rainonlymean(dd)^2)/rainonlyvar(dd);
        theta(dd) = rainonlyvar(dd)/rainonlymean(dd);
    end
end

rainstatsgamma = [rainprob, k, theta];
rainstats = [rainmean, rainstd];
%csvwrite('data\rainstats.dat',rainstats)
csvwrite('SydneyGamma.dat',rainstatsgamma)