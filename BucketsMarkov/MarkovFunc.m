%Function file for obtaining the total_tba parameter space of the rainfall
%Markov process distribution

function solvector = MarkovFunc(total_tba)
rainstatsfile = 'Rainfall_Files\NATT_DarwinGamma.dat';
Vgf = 37.11; %field capacity of grass bucket
VR = 148.44; %111.33; %capacity of tree bucket
Vj = VR*5/6; %(1-2/9); %required subsoil water for seedling access
Vg_evap = Vgf*2/3; %water necessary for evaporation
runnumber = 1000; %number of realizations for dry season

omega = 0.715/10; %biomass to water consumed constant

%other constants
g = 0.007; %grass growth rate
gamma = 0.9; %grass drink rate
epsilon = Vgf - Vg_evap; %evaporation rate
%setup rain and initial conditions
Rain = Rainfall(rainstatsfile,'M1G'); %was running BG
Gam0 = Vgf;
G0 = 0.5;
tdrink = total_tba*omega;
%the event function causes the solver to stop when Gam=0
options = odeset('Events',@eventfunc,'NonNegative',1:length([Gam0,G0]));
tvec = linspace(0,365,365);
odefun = @(t,y) ODEs(t,y,Vgf,gamma,g,tdrink,epsilon,Vg_evap,Rain);
%data vectors
drystart = -1*ones(runnumber,1);
dryend = -1*ones(runnumber,1);
drydays = zeros(runnumber,1);
juvsurv = ones(runnumber,1);

for yr = 1:runnumber,
    %%% first run simulation to find start of dry season %%%
    [t,y,te,ye,ie] = ode45(odefun,tvec,[Gam0,G0],options);
    if isempty(te) %rarely, for really low tba, the soil may not dry out
        drystart(yr) = tvec(end);
        dryend(yr) = tvec(end);
        drydays(yr) = 0;
        continue
    end
    drystart(yr) = floor(te); %day dry season started
    
    %%% now run Markov process until R and Gam are both full. Ignore if
    %%% this happens really early though.
    tt = drystart(yr);
    water = VR;
    cap = VR + Vgf;
    while 1
        water = [water; water(end) + Rain.getRain(tt) - tdrink];
        if water(end) >= cap, %end of dry season condition
            if tt >= drystart(yr) + 150,
                if dryend(yr) == -1,
                    dryend(yr) = tt;
                end
                break
            else %this may be too early. record, but keep going
                if dryend(yr) == -1,
                    dryend(yr) = tt;
                end
                water(end) = cap; %stay put
            end
        end
        %maybe we kept going and the water level decreased significantly
        %again
        if water(end) < VR && dryend(yr) ~= -1,
            dryend(yr) = -1;
        end
        %boundary condition
        %water can't go below zero
        if water(end) < 0,
            water(end) = 0;
        end
        tt = tt+1; %increment day
    end
    %dry season is over.
    
    %Record statistics
    for day = 1:length(water),
        if water(day) == 0,
            drydays(yr) = drydays(yr)+1;
        end
        if water(day) < Vj,
            juvsurv(yr) = 0;
        end
    end
end

solvector = [drystart,dryend,drydays,juvsurv];