%Continuous-time AusSavanna model.
%Solves the equations in BuckSODEs.m
%Requires Calendar.m
clear

global Vg delta gamma VR g c rain Vgf Vg_evap omegaT epsilon

%% Switches and Data Source
simulation_name = 'Darwin1000Fine'; %for saving simulation results and plotting

STOCRUN = 0;
STOCMETHOD = 'M1G'; %'BG' or 'M1G' currently supported (Binomial-Gamma, Markov-Gamma)
rainstatsfile = 'Rainfall_Files\NATT_DarwinMarkov1Gam.dat';

switch STOCRUN
    case 0
        %load a pre-generated rainfall history
        rain = csvread('Stoc_DarwinRain_2000Yr.dat');
        rain = rain(1:365*1000);
        %rain = rain(365*500+1:365*506);
        endYr = floor(length(rain)/365);
        %duplicate last day of rain so solver can finish properly
        rain = [rain;rain(end)];
    case 1
        %INPUT years to run
        endYr = 500;
        %generate stochastic rain
        disp(['Generating stochastic rain for ' num2str(endYr) ' years...'])
        RainGen = Rainfall(rainstatsfile,'M1G');
        rain = zeros(endYr*365+1,1);
        for dd = 1:endYr*365+1
            rain(dd) = RainGen.getRain(dd);
        end
    otherwise
        error('STOCRUN must be either 1 or 0')
end

Cal = Calendar(endYr); %Initialize calendar

%% Constants
%BUCKET CONSTANTS
Vgf = 37.11; %field capacity for grass
Vg = 77.31; %saturation capacity of grass bucket
Vg_evap = Vgf*2/3; %minimum amount of topsoil water for evaporation to occur
VR = 148.44; %subsoil field capacity
Vj = VR*5/6; %VR*0.5; %seedling limit in tree bucket, from the top
delta = Vg-Vgf; %Drain rate for saturated topsoil water (mm/day)
epsilon = Vgf - Vg_evap; %evaporation rate (mm/day)
%TREE MORTALITY
deathR = 0.0032; %per day death rate for stressed trees
deathRJ = 1; %per day death rate for stressed juveniles
%RECRUITMENT, WATER CONSUMPTION, AND GRASS CURE RATE
seedlings = 265; %seedlings to add during seedling event
seedmonth = 1; %month seedlings sprout
g = 0.007; %grass recruitment rate, tonnes/day
gamma = 0.9; %grass water usage rate
treeDrinkR = 0.715/10; %mm of water per m^2 of basel area (0.715 cm/m^2)
c = 0.1; %grass cure rate
%TREE VECTOR SPECIFICATIONS
%Solution vector will have diameter size classes from 0mm to 1m. The oldest tree
%is 500 years, so that's 2mm per year. We split this up into monthly
%increments of 2/12 mm per month.
treesteps = 12; %12 months in a year, so 12 age classes per year
sizeclslength = 500*treesteps; %the constant here represents the oldest tree (in years)
increm = 2/treesteps; %mm per year, divided by number of months
% !!! - was 2.5/treesteps??
%NATURAL TREE DEATH VECTOR. Model waiting time until death with a gamma distribution
%(typical choice). choose params such that mean = d_k*d_th, and variance = d_k*(d_th)^2
d_k = 100;
d_th = 4;
nuvec = zeros(sizeclslength,1);
ttimes = 1/treesteps:1/treesteps:sizeclslength/treesteps;
nuvec(1:sizeclslength) = (gampdf(ttimes,d_k,d_th)/treesteps)./(1-gamcdf(ttimes,d_k,d_th));
%this now represents a vector of probabilities of dying at each size class

%% Initial conditions
intwatergrass = Vgf; %starting water in grass bucket
intwatertrees = VR; %starting water in tree bucket
intlivegrass = 0; %Initial grass biomass
%Tree inital conditions
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
%500 yr spin-up
% odevars = csvread('Data\500YrDarwinWG.csv');
% intwatergrass = odevars(1);
% intwatertrees = odevars(2);
% intlivegrass = odevars(3);
% intsize = csvread('Data\500YrDarwinTrees.csv');

%% Initializations
% Pass initial conditions into the solution vector, and initialize solution
% vectors for buckets and grass
solvector = zeros(sizeclslength,endYr*12+1); %this will record the stand at the beginning of each month
solvector(:,1) = intsize;
clearvars intsize
waterreqbydbh = zeros(sizeclslength,1);
%record solutions for the beginning of each day.
%initial conditions are first entry in solution vector.
Gam = zeros(endYr*365+1,1); %avoid fencepost error
R = zeros(endYr*365+1,1);
G = zeros(endYr*365+1,1);
Gam(1) = intwatergrass;
R(1) = intwatertrees;
G(1) = intlivegrass;

%% Pre-loop calculations
% calculate how much a tree in each size class would drink
for jj = 1:sizeclslength,
    waterreqbydbh(jj) = treeDrinkR*(pi*((jj-1)*increm/1000/2).^2);
end
tbacalc = zeros(sizeclslength,1);
for jj = 1:sizeclslength, 
    tbacalc(jj) = pi*((jj-1)*increm/1000/2).^2;
end
%options to pass to ODE solver
options = odeset('NonNegative',1:3,'RelTol',1e-5); %this RelTol means that 
    %we may not see R==0. The heaviside function approximation will
    %also cause problems as Gam or R get small

%% Solve
%We loop over months here, solving the system of ODEs each month and then
%updating the vector of tree size classes.
fullrun_timer = tic;
curmonth = 1; %counter for months
while Cal.EndFlag == 0, %Finish check
    disp(['Simulating year ' num2str(Cal.Year) ', month ' num2str(Cal.Month)])
    %SOLVE FOR CONTINUOUS-TIME WATER DYNAMICS
    %solve during each day of the current month, ending at the beginning of
    %the first day of the next month.
    num_days = Cal.DaysInMonth(Cal.Month);
    tvec = Cal.Day:(Cal.Day + num_days);
    %get water usage rate for all trees in the stand for this month
    omegaT = solvector(:,curmonth)'*waterreqbydbh;
    %solve ODEs for the current month
    [t,y] = ode45(@BuckSODEs,tvec,[Gam(Cal.Day),R(Cal.Day),G(Cal.Day)],options);
    %record solutions. y(1,:) is just the initial conditions.
    Gam(Cal.Day:Cal.Day+num_days) = y(:,1);
    R(Cal.Day:Cal.Day+num_days) = y(:,2);
    G(Cal.Day:Cal.Day+num_days) = y(:,3);
    %CALCULATE STRESS ON TREES
    %count the number of days that began dry for trees/seedlings
    stresscnt = 0;
    juvstress = 0;
    for jj=Cal.Day:Cal.Day+num_days-1,
        %zero may not be simulated exactly due to RelTol. approximate it.
        if R(jj) < 0.5 && Gam(jj) < 0.5,
            stresscnt = stresscnt + 1;
            juvstress = juvstress + 1;
        elseif R(jj) < Vj && Gam(jj) < 0.5,
            juvstress = juvstress + 1;
        end
    end
    survrate = (1-deathR)^stresscnt; %survival rate for trees this month
    survrateJ = (1-deathRJ)^juvstress; %suvival rate for seedlings this month
    %UPDATE TREES
    %increment the calendar so that it represents the current day.
    for ii=1:num_days
        Cal.nextDay
    end
    curmonth = curmonth + 1; %update the current month
    %add seedlings?
    if Cal.PrevMonth == seedmonth,
        %add seedlings to the first size class, minus any mortality
        solvector(1,curmonth) = survrateJ*seedlings;
    else
        solvector(1,curmonth) = 0;
    end
    %seedlings grow
    for jj = 2:treesteps, %these are the seedling size classes
        solvector(jj,curmonth) = solvector(jj-1,curmonth-1)*survrateJ;
    end
    %the rest of the trees grow, minus any mortality
    for jj = treesteps+1:sizeclslength,
        solvector(jj,curmonth) = solvector(jj-1,curmonth-1)*survrate*(1-nuvec(jj-1));
    end
end

disp(['Total elapsed time for simulation: ' num2str(toc(fullrun_timer)) ' seconds.'])
%save solution
save(simulation_name,'Gam','R','G','Vgf','Vg','VR','endYr','solvector','treesteps','tbacalc');

%plot solution
AusSavanna2ContModel_plot(Gam,R,G,Vgf,Vg,VR,endYr,solvector,treesteps,tbacalc);

%old plotting
% %plot water and grass
% figure
% subplot(3,1,1)
% plot(Gam,'r')
% title(['Water in top bucket, F_\Gamma = ' num2str(Vgf) ', V_\Gamma = ' ...
%     num2str(Vg)])
% xlabel('Time (days)')
% ylabel('mm water')
% subplot(3,1,2)
% plot(R,'b')
% title(['Water in bottom bucket, V_R = ' num2str(VR)])
% xlabel('Time (days)')
% ylabel('mm water')
% subplot(3,1,3)
% plot(G,'g')
% title('Grass biomass')
% xlabel('Time (days)')
% ylabel('tons')
% 
% %plot trees
% timecnt = linspace(0,endYr,endYr*12+1); %units are years
% totaltrees = sum(solvector(treesteps:end,:)); %neglect very small seedlings
% %Commented amounts are for 0 to 1m in 400 yrs, 0 to 1m in 500 yrs
% %0-15cm, 15-30cm, 30-50cm, 50cm-1m
% smalltrees = sum(solvector(treesteps:76*treesteps,:));%sum(solvector(treesteps:61*treesteps,:));
% mediumtrees = sum(solvector(76*treesteps+1:151*treesteps,:));%sum(solvector(61*treesteps+1:121*treesteps,:));
% largetrees = sum(solvector(151*treesteps+1:251*treesteps,:));%sum(solvector(121*treesteps+1:201*treesteps,:));
% hugetrees = sum(solvector(251*treesteps+1:end,:));%sum(solvector(201*treesteps+1:end-notreelength,:));
% tba = tbacalc'*solvector;
% figure
% subplot(3,1,1)
% plot(timecnt,totaltrees)
% xlim([0 endYr])
% title('Stem Count')
% xlabel('Year')
% ylabel('Number of Trees')
% subplot(3,1,2)
% semilogy(timecnt,smalltrees,'k',timecnt,mediumtrees,'g',timecnt,largetrees,'b',timecnt,hugetrees,'r')
% xlim([0 endYr])
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
% xlim([0 endYr])
% title('TBA per year')
% xlabel('Year')
% ylabel('m^2 ha^{-1}')