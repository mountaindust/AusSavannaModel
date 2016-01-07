%Full Savanna model.  Fire, stochastic rainfall option, stochastic wind
%option.  Tree sizes are updated on a monthly time step and recorded
%yearly.  Litter is reported yearly, grass monthly.

simulation_name = 'Darwin2000YrFire03M5t11_2'; %for saving simulation results and plotting

%% Switches and Data Source
STOCRUN = 0; % 0: Use a file of daily rainfall data, 1: Generate stocastic rain using STOCMETHOD
STOCMETHOD = 'M1G'; %'BG' or 'M1G' currently supported (Binomial-Gamma, Markov-Gamma)
rainstatsfile = 'Rainfall_Files\SydneyMarkov1Gam.dat'; %If STOCRUN=1, file with stoc parameter info
                                                       %  matching the stochastic method (STOCMETHOD)
STOCWIND = 1; %For fire process. 1: Use stochastic wind. 0: Use wind average.

%% Load data, form solution vector
switch STOCRUN
    case 0
        %INPUT daily rainfall data, 365 days
        %rain = csvread('Rainfall_Files\NATT_Darwin.dat');
        rain = csvread('Stoc_DarwinRain_2000Yr.dat');
        %rain = rain(1:365*1000);
        %rain = rain(365*500+1:end);
        %Years to run (to end of data)
        endYr = floor(length(rain)/365);
    case 1
        %INPUT years to run
        endYr = 2000; %3000;

        %Create stocastic rain
        disp(['Generating stochastic rain for ' num2str(endYr) ' years...'])
        rain = zeros(endYr*365,1);
        RainObj = Rainfall(rainstatsfile,STOCMETHOD);
        
        for dd = 1:endYr*365
            rain(dd) = RainObj.getRain(dd);
        end
        disp('Done.')
    otherwise
        error('STOCRUN must be either 1 or 0')
end

%Initalize solution vector of size classes from 0mm to 1m. The oldest tree
%is 500 years, so that's 2mm per year onto the diameter. We split this up into monthly
%increments of 2/12 mm per month.
treesteps = 12; %12 months in a year
sizeclslength = 500*treesteps; %the constant here represents the oldest tree (in years)
increm = 2/treesteps; %mm per year, divided by number of months
% !!! - was 2.5/treesteps??
notreelength = 3; %Keep track of tree litter, live grass, and dead grass biomass
solvector = zeros(sizeclslength + notreelength,endYr+1);

%% Build Calendars
Cal = Calendar(endYr);
FCal = FireCal(1,1/3,5:11); %FireCal(0,4,6); %FireCal(0,freq in years, end of month to burn)
                     %OR FireCal(1,prob of burn each month,0) - stocastic
                     %OR FireCal(1,prob of burn in a year,month to burn) - stocastic
                     %OR FireCal(0,0,anything) - no fire
Fres = 5:11; %Restrict fire to be able to occur in these months only.

%% Inital conditions
intsize = zeros(sizeclslength,1);
sizedata = csvread('data\TreePop_DAC.txt'); %INPUT initial size vector
sizedata = round(sizedata/increm)+1; %convert to size classes
for ii = 1:length(sizedata),
    if sizedata(ii)<=sizeclslength,
        intsize(sizedata(ii)) = intsize(sizedata(ii)) + 1;
    else
        intsize(end) = intsize(end) + 1;
    end
end
%500 yr spin-up from continuous model
%intsize = csvread('Data\500YrDarwinTrees.csv');

%% Constants
%BUCKET CONSTANTS
Vgf = 37.11; %V*3/11; %topsoil field capacity
Vg = 77.31; %topsoil saturation capacity
Vg_evap = Vgf*2/3; %everything above this amount is lost to evaporation at the end of each day
V = 148.44; %132; %subsoil field capacity
Vj = V*5/6; %seedling limit in tree bucket (from bottom) 0.9,0.6,0.5,0.4
%Vj = V*2/6;
%DEATH/RESPROUT
deathR = 0.0032; %per day death rate for stressed trees
deathRJ = 1; %per day death rate for stressed juveniles
resproutR = 0.9; %resprout rate -- this applies only to fire death
resproutclass = 7*treesteps; %size class at which trees resprout
%RECRUITMENT, WATER CONSUPTION, AND GRASS CURE/DECOMP
seedlings = 265; %seedlings to add during seedling event
seedmonth = 1;  %month seedlings sprout
grassR = 0.007; %grass recruitment rate, grass/day
grassDrinkR = 0.9; %mm of water one ton of grass drinks per day
treeDrinkR = 0.715/10; %mm of water per m^2 of basel area (0.715 cm/m^2)
grasscureR = 0.1; %grass curing rate per dry day
grassdecompR = 0.8/365; %grass decomp rate per year
% grassdecompR = (1-exp(-grassdecompConst/12))/365; %more accurate decomp rate??
%LITTER RATES
litterdecompR = 0.8/365; %litter decomp rate per day
tau = -2.0*pi*(42/365 - 0.75); %used in new litter calculation, 42 is TauMin
%FIRE CONSTANTS
switch STOCWIND
    case 0
        wind = 17.84; %mean value from windmp, Darwin.wthr
    case 1
        windavg = 17.84; %mean value for windmp, Darwin.wthr
    otherwise
        error('STOCWIND must be either 0 or 1')
end
rh = [70,72,67,52,43,38,37,40,47,52,58,65]; %relative humidity pm (rhp) from Darwin.wthr
temp = 30.8; %mean value from tmpp, Darwin.wthr
a1 = -0.098;
a2 = 0.029;
b1 = 0.037;
b2 = -0.01;
%INITIAL CONDITIONS
intwatertrees = V; %starting water in tree bucket
intwatergrass = Vgf; %starting water in grass bucket
intlivegrass = 0; %Initial grass biomass
%500 yr spin-up
% odevars = csvread('Data\500YrDarwinWG.csv');
% intwatergrass = odevars(1);
% intwatertrees = odevars(2);
% intlivegrass = odevars(3);
intdeadgrass = 0; %Initial dead grass biomass
inttreelitter = 0; %Initial tree litter
%NATURAL DEATH VECTOR. Model waiting time until death with a gamma distribution
%(typical choice). choose params such that mean = d_k*d_th, and variance = d_k*(d_th)^2
d_k = 100;
d_th = 4;
nuvec = zeros(sizeclslength+notreelength,1);
ttimes = 1/treesteps:1/treesteps:sizeclslength/treesteps;
nuvec(1:sizeclslength) = (gampdf(ttimes,d_k,d_th)/treesteps)./(1-gamcdf(ttimes,d_k,d_th));
%this now represents a vector of probabilities of dying at each size class

%% Initializations
% Pass initial conditions into the solution vector
solvector(:,1) = [intsize; inttreelitter; intlivegrass; intdeadgrass];
clearvars intsize inttreelitter
waterreqbydbh = zeros(sizeclslength,1);
recordFireSurR = zeros(sizeclslength,endYr);
recordIntense = zeros(endYr,1);
recordGrassDry = zeros(endYr*365,1);
%the following are for record keeping only
monthlyLiveGrass = zeros(endYr*12,1);
monthlyDeadGrass = zeros(endYr*12,1);
monthlyLitter = zeros(endYr*12,1);

%% Pre-loop calculations
% calculate how much a tree in each size class would drink
for jj = 1:sizeclslength,
    waterreqbydbh(jj) = treeDrinkR*(pi*((jj-1)*increm/1000/2).^2);
end
waterreqbydbh = [waterreqbydbh; zeros(notreelength,1)];
tbacalc = zeros(sizeclslength,1);
for jj = 1:sizeclslength, 
    tbacalc(jj) = pi*((jj-1)*increm/1000/2).^2;
end

%debug
all_watergrass = [];
all_watertrees = [];

%% Main Loop
tic;
while Cal.EndFlag == 0, %Finish check
    cursol = zeros(sizeclslength + notreelength,treesteps+1); %used to store inter-year solutions.
    cursol(:,1) = solvector(:,Cal.Year);
    year = Cal.Year;
    
    while Cal.Year == year, %monthly loop (to control water and cursol resets, and record solution)
        month = Cal.Month;
        waterreq = cursol(:,month)'*waterreqbydbh;
        watergrass = zeros(Cal.DaysInMonth(month),1); %grass bucket, per day
        watertrees = zeros(Cal.DaysInMonth(month),1); %tree bucket, per day
        livegrassamt = zeros(Cal.DaysInMonth(month),1); %inter-monthly grass amount
        deadgrassamt = zeros(Cal.DaysInMonth(month),1); %inter-monthly dead grass amount
        
        while Cal.Month == month, %daily loop
            %Get current water and grass amounts.
            if Cal.DayOfMonth == 1,
                prv_grass_water = intwatergrass;
                prv_grass = intlivegrass;
                prv_deadgrass = intdeadgrass;
                prv_trees_water = intwatertrees;
            else
                prv_grass_water = watergrass(Cal.DayOfMonth-1);
                prv_grass = livegrassamt(Cal.DayOfMonth-1);
                prv_deadgrass = deadgrassamt(Cal.DayOfMonth-1);
                prv_trees_water = watertrees(Cal.DayOfMonth-1);
            end
                 
            watergrass(Cal.DayOfMonth) = prv_grass_water + rain(Cal.Day); %rain (maybe) falls into the grass bucket
            
            %lose water in excess of saturation capacity
            if watergrass(Cal.DayOfMonth) > Vg
                watergrass(Cal.DayOfMonth) = Vg;
            end
            
            %grass uses water first.
            watergrass(Cal.DayOfMonth) = max([0,watergrass(Cal.DayOfMonth) - grassDrinkR*prv_grass]);
            
            draintoday = 0;
                
            %trees drink from the grass bucket first, then tree bucket
            if watergrass(Cal.DayOfMonth) >= waterreq,
                watergrass(Cal.DayOfMonth) = watergrass(Cal.DayOfMonth) - waterreq;
                treewaterreq = 0;
            else
                treewaterreq = waterreq - watergrass(Cal.DayOfMonth);
                watergrass(Cal.DayOfMonth) = 0;
            end
                
            %if the grass bucket is over field capacity...
            if watergrass(Cal.DayOfMonth) > Vgf,
                %record the overflow (overflow over saturation is already lost)
                extra = min([watergrass(Cal.DayOfMonth) - Vgf,Vg - Vgf]); 
                watergrass(Cal.DayOfMonth) = Vgf;
            else
                extra = 0;
            end
                
            watertrees(Cal.DayOfMonth) = max([0,min([(prv_trees_water + extra + draintoday - treewaterreq),V])]); %tree bucket calculation
                
            %update grass amounts
            if watergrass(Cal.DayOfMonth) > 0,
                livegrassamt(Cal.DayOfMonth) = prv_grass + grassR;
                deadgrassamt(Cal.DayOfMonth) = prv_deadgrass*(1-grassdecompR);
            elseif watergrass(Cal.DayOfMonth) == 0,
                recordGrassDry(Cal.Day) = 1;
                livegrassamt(Cal.DayOfMonth) = prv_grass*(1-grasscureR);
                deadgrassamt(Cal.DayOfMonth) = prv_deadgrass*(1-grassdecompR) + prv_grass*grasscureR;
            end
            
            %evaporation loss
            if watergrass(Cal.DayOfMonth) > Vg_evap
                watergrass(Cal.DayOfMonth) = Vg_evap;
            end
            
            Cal.nextDay; %advance day
        end %month is over
        
        %calculate total basel area
        tba = [tbacalc;zeros(notreelength,1)]'*cursol(:,month);
        
        %litter aquire this season (non coarse) as a non-linear
        %funciton of time and tba.  See notes- solved integral form follows.
        litter = 0.35*tba*(Cal.DaysInMonth(month)/365 +...
            1/(2*pi)*(cos(2*pi*sum(Cal.DaysInMonth(1:month-1))/365 + tau) - cos(2*pi*sum(Cal.DaysInMonth(1:month))/365 + tau)));
        
        %calculate water stress days for trees
        %all_watergrass = [all_watergrass;watergrass];
        %all_watertrees = [all_watertrees;watertrees];
        
        stresscnt = 0;
        juvstress = 0;
        for jj=1:Cal.DaysInMonth(month),
            if watertrees(jj) == 0  && watergrass(jj) == 0,
                stresscnt = stresscnt + 1;
                juvstress = juvstress + 1;
            %elseif watertrees(jj) == 0,
                %stresscnt = stresscnt + 1;
            elseif watertrees(jj) <= Vj && watergrass(jj) == 0,
                juvstress = juvstress + 1;
            end
        end
        survrate = (1-deathR)^stresscnt; %survival rate for trees this month
        survrateJ = (1-deathRJ)^juvstress; %suvival rate for seedlings this month
        
        %UPDATE
        if Cal.PrevMonth == seedmonth,
            cursol(1,month+1) = survrateJ*seedlings;
        else
            cursol(1,month+1) = 0;
        end
        for jj = 2:treesteps,
            cursol(jj,month+1) = cursol(jj-1,month)*survrateJ; %trees are considered seedlings until they live for a full year
        end
        for jj = treesteps+1:resproutclass-1,
            cursol(jj,month+1) = cursol(jj-1,month)*survrate*(1-nuvec(jj-1));
        end
        cursol(resproutclass,month+1) = cursol(resproutclass-1,month)*survrate*(1-nuvec(resproutclass-1));% +...
        %    [zeros(1,resproutclass), resproutR*(1-mortrate)*ones(1,sizeclslength-resproutclass), zeros(1,notreelength)] * cursol(:,month); %resprouts
        for jj = resproutclass+1:sizeclslength,
            cursol(jj,month+1) = cursol(jj-1,month)*survrate*(1-nuvec(jj-1));
        end
        cursol(sizeclslength+1,month+1) = cursol(sizeclslength+1,month)*(1-min(1,litterdecompR*Cal.DaysInMonth(month))) + litter;
        monthlyLitter((Cal.PrevYear-1)*12+Cal.PrevMonth) = cursol(sizeclslength+1,month+1);
        cursol(sizeclslength+2,month+1) = livegrassamt(end);
        monthlyLiveGrass((Cal.PrevYear-1)*12+Cal.PrevMonth) = livegrassamt(end);
        cursol(sizeclslength+3,month+1) = deadgrassamt(end);
        monthlyDeadGrass((Cal.PrevYear-1)*12+Cal.PrevMonth) = deadgrassamt(end);
        
        %check for fire, calculate intensity, and burn
        if (FCal.IsFire(month, Cal.Year) == 1 || (month==12 && FCal.IsFire(month, Cal.Year-1) == 1))...
                && ismember(month,Fres),
            if STOCWIND == 1,
                wind = raylrnd(windavg*sqrt(2/pi));
            end
            CureR = 100*(cursol(sizeclslength+1,month+1)+cursol(sizeclslength+3,month+1))/(sum(cursol(sizeclslength+1:sizeclslength+3,month+1)));
            M = (97.7+4.06*rh(month))/(temp+6) - 0.00854*rh(month) + 3000/CureR - 30;
            if M<=12,
                phim = exp(-0.108*M);
            else
                if wind<=10,
                    phim = 0.684 - (0.0342*M);
                else
                    phim = 0.547 - (0.0228*M);
                end
            end
            phic = 1.120/(1+59.2*exp(-0.124*(CureR-50)));
            if wind<=5,
                Rmax = (0.054+0.269*wind)*phim*phic;
            else
                Rmax = (1.399+0.838*(wind-5)^0.844)*phim*phic;
            end
            Rmax = Rmax/3.6; %unit conversion?
            intense = 2*Rmax*(cursol(sizeclslength+1,month+1)+cursol(sizeclslength+3,month+1));
            intense = max([0,intense]);
            recordIntense(Cal.Year) = intense;
            FsurvR = zeros(sizeclslength+notreelength,1);
            for jj = 1:sizeclslength,
                FsurvR(jj) = min([1+a1*intense+b1*intense*log(jj*increm/10),1+a2*intense+b2*intense*log(jj*increm/10)]);
                if FsurvR(jj)<0,
                    FsurvR(jj)=0;
                elseif FsurvR(jj)>1,
                    FsurvR(jj)=1;
                end
            end
            recordFireSurR(:,Cal.Year) = FsurvR(1:sizeclslength);
            rsvec = zeros(sizeclslength+notreelength,1);
            rsvec(resproutclass) = cursol(resproutclass:sizeclslength,month+1)'*(1-FsurvR(resproutclass:sizeclslength))*resproutR; %resprouts from fire
            cursol(:,month+1) = cursol(:,month+1).*FsurvR + rsvec;
            livegrassamt(end) = 0;
            deadgrassamt(end) = 0;
        end
        
        %Record new initial values
        intlivegrass = livegrassamt(end);
        intdeadgrass = deadgrassamt(end);
        intwatergrass = watergrass(end);
        intwatertrees = watertrees(end);
    end %year is over
    
    %feedback
    if mod(year,500) == 0,
        disp(['Year ', num2str(year), ' finished.'])
    end
    %record solution each year
    solvector(:,year+1) = cursol(:,end);
end
toc

%% some output

save(simulation_name,'endYr','solvector','treesteps','notreelength',...
    'tbacalc','sizeclslength','monthlyLiveGrass','monthlyDeadGrass')

%plot output
AusSavanna2_plot(endYr,solvector,treesteps,notreelength,tbacalc,...
    sizeclslength,monthlyLiveGrass,monthlyDeadGrass)

%old plotting routine
% timecnt = 1:endYr+1;
% totaltrees = sum(solvector(treesteps:end-notreelength,:)); %neglect very small seedlings
% %Commented amounts are for 0 to 1m in 400 yrs, 0 to 1m in 500 yrs
% %0-15cm, 15-30cm, 30-50cm, 50cm-1m
% smalltrees = sum(solvector(treesteps:76*treesteps,:));%sum(solvector(treesteps:61*treesteps,:));
% mediumtrees = sum(solvector(76*treesteps+1:151*treesteps,:));%sum(solvector(61*treesteps+1:121*treesteps,:));
% largetrees = sum(solvector(151*treesteps+1:251*treesteps,:));%sum(solvector(121*treesteps+1:201*treesteps,:));
% hugetrees = sum(solvector(251*treesteps+1:end-notreelength,:));%sum(solvector(201*treesteps+1:end-notreelength,:));
% tba = [tbacalc;zeros(notreelength,1)]'*solvector;
% figure
% subplot(3,1,1)
% plot(timecnt,totaltrees)
% title('Stem Count')
% xlabel('Year')
% ylabel('Number of Trees')
% subplot(3,1,2)
% semilogy(timecnt,smalltrees,'k',timecnt,mediumtrees,'g',timecnt,largetrees,'b',timecnt,hugetrees,'r')
% title('Trees by size (diameter)')
% xlabel('Year')
% ylabel('Number of trees')
% %legend('Juvenile','Adult','Mature','Yggdrasil')
% legend('0-15cm','16-30cm','31-50cm','51cm-1m')
% % subplot(4,1,3)
% % beginyear = 20;
% % plot(timecnt(beginyear:end),smalltrees(beginyear:end),'k',timecnt(beginyear:end),mediumtrees(beginyear:end),'g',timecnt(beginyear:end),largetrees(beginyear:end),'b',timecnt(beginyear:end),hugetrees(beginyear:end),'r')
% % title('Trees by size (diameter)')
% % xlabel('Year')
% % ylabel('Number of trees')
% % %legend('Juvenile','Adult','Mature','Yggdrasil')
% % legend('0-15cm','16-30cm','31-50cm','51cm-1m')
% subplot(3,1,3)
% plot(timecnt,tba)
% title('TBA per year')
% xlabel('Year')
% ylabel('m^2 ha^{-1}')
% slowtimecnt = 1/12:1/12:endYr;
% 
% % figure
% % subplot(2,1,1)
% % semilogy(timecnt,smalltrees,'k',timecnt,mediumtrees,'g',timecnt,largetrees,'b',timecnt,hugetrees,'r')
% % title('Trees by size (diameter)')
% % xlabel('Year')
% % ylabel('Number of trees')
% % legend('0-15cm','16-30cm','31-50cm','51cm-1m')
% % subplot(2,1,2)
% % plot(timecnt,tba)
% % title('TBA per year')
% % xlabel('Year')
% % ylabel('m^2 ha^{-1}')
% % slowtimecnt = 1/12:1/12:endYr;
% 
% figure
% subplot(3,1,1)
% plot(timecnt,solvector(sizeclslength+1,:))
% title('Tree Litter')
% xlabel('Year')
% ylabel('tons')
% subplot(3,1,2)
% plot(slowtimecnt,monthlyLiveGrass)
% title('Live Grass')
% xlabel('Year')
% ylabel('tons')
% subplot(3,1,3)
% plot(slowtimecnt,monthlyDeadGrass)
% title('Dead Grass')
% xlabel('Year')
% ylabel('tons')