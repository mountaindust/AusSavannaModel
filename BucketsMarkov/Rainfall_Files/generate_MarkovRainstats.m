%convert rain data into daily mean/varience for a one year period
clear

rain = csvread('NATT_Katherine_Council.dat'); %INPUT daily rainfall data, 365 days a year

lngth = length(rain);
rain = rain(1:floor(lngth/365)*365); %make sure rain data is for an integer number of years
lngth = length(rain);
yrs = lngth/365;
rain = reshape(rain,365,yrs);

rainmean = mean(rain,2);
rainstd = std(rain,0,2);

%find probability that it rains each day given the status of the last day, 
%and collect rainy day only stats
didrain = zeros(size(rain));
rainprob_didrain = zeros(365,1);
rainprob_norain = zeros(365,1);
rainonlymean = zeros(365,1);
rainonlyvar = zeros(365,1);
k = zeros(365,1);
theta = zeros(365,1);
for dd=1:365,
    clearvars rainydays
    rainydays = 0;
    prevrain = zeros(yrs,1);
    for ee=1:yrs,
        if rain(dd,ee)>0,
            didrain(dd,ee)=1;
            rainydays = [rainydays, rain(dd,ee)];
        end
        %record whether it rained or not the previous day
        if dd ~= 1,
            if rain(dd-1,ee)>0,
                prevrain(ee)=1;
            end
        else
            if ee ~= 1 && rain(365,ee-1)>0,
                prevrain(ee)=1;
            end
        end
    end
    
    %Get probabilities
    %skip first day of first year
    if dd ~= 1,
        fyr = 1;
    else
        fyr = 2;
    end
    yrs_adj = yrs+1-fyr; %get correct prob calculation below
    if sum(prevrain(fyr:end))>0 && (yrs_adj-sum(prevrain(fyr:end)))>0  %avoid division by zero
        for ee=fyr:yrs,
            if prevrain(ee) == 1,
                %count the number of days it rained given rain yesterday
                if didrain(dd,ee) == 1,
                    rainprob_didrain(dd) = rainprob_didrain(dd)+1;
                end
            else
                if didrain(dd,ee) == 1,
                    rainprob_norain(dd) = rainprob_norain(dd)+1;
                end
            end
        end
        %compute probabilities for day dd
        rainprob_didrain(dd) = rainprob_didrain(dd)/sum(prevrain(fyr:end));
        rainprob_norain(dd) = rainprob_norain(dd)/(yrs_adj-sum(prevrain(fyr:end)));
    %deal with lopsided cases
    elseif sum(prevrain(fyr:end))==0,
        rainprob_didrain(dd) = 0;
        rainprob_norain(dd) = rainprob_norain(dd)/yrs_adj;
    elseif yrs_adj==sum(prevrain(fyr:end)),
        rainprob_didrain(dd) = rainprob_didrain(dd)/sum(prevrain);
        rainprob_norain(dd) = 0;
    end
    %rain mean/varience
    if length(rainydays)==1,
        rainonlymean(dd) = 0;
        rainonlyvar(dd) = 0;
    else
        rainydays = rainydays(2:end);
        rainonlymean(dd) = mean(rainydays);
        rainonlyvar(dd) = var(rainydays);
    end
    
    %Calculate Gamma parameters from mean and variance
    %These will not differentiate based on previous day
    if rainonlyvar(dd) == 0,
        k(dd) = 0;
        theta(dd) = 0;
        rainprob_didrain(dd) = 0; %here we lose single year rain events.
        rainprob_norain(dd) = 0;
        %An alternative is to record these events and take a mean, applying
        %that rainfall if rain occurs on that day.
    else
        k(dd) = (rainonlymean(dd)^2)/rainonlyvar(dd);
        theta(dd) = rainonlyvar(dd)/rainonlymean(dd);
    end
end

rainstatsM1G = [rainprob_didrain, rainprob_norain, k, theta];
rainstats = [rainmean, rainstd];
%csvwrite('data\rainstats.dat',rainstats)
csvwrite('NATT_Katherine_CouncilMarkov1Gam.dat',rainstatsM1G)