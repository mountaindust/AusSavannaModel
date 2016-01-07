%Plot dynamics from both continuous- and discrete-time models together
%All x-axis units will be in years

function AusSavanna2_plotDoubleBW(cont_model,discr_model)

%quick font sizes
title_size = 19;
tick_size = 14;
label_size = 16;
legend_size = 11;
%quick label offsets
ldx = 105;
ldy = 50;

figure

%subplot layout
C = {{{['-g']};{['-g']};{['-g']}};{{['-g']};{['-g']};{['-g']}}};
[h,labelfontsize] = subplotplus(C);

%% Plot continuous model dynamics on first 3 subplots

%skip first few years in plot?
skipyears = 0;
%shift years of x-axis
shift_years = 500;

load(cont_model)
skipshiftyears = shift_years+skipyears;
timecnt = linspace(skipshiftyears,endYr+shift_years,(endYr-skipyears)*365+1); %units are years
day1 = 1+skipyears*365;

%plot water dynamics and live grass biomass

%topsoil water
%subplot(6,1,1)
axnum = 1;
set(gcf,'CurrentAxes',h(axnum));
plot(timecnt,Gam(day1:end),'k')
set(gca,'FontSize',tick_size,'xticklabel',[])
xlim([skipshiftyears endYr+shift_years])
xlabel('Time (years)','FontSize',label_size)
ylabel({'topsoil','water (mm)'},'FontSize',label_size)
%title for the continuous model plots
title('Short Term Grass and Moisture Dynamics','FontSize',title_size)

%subsoil water
%subplot(6,1,2)
axnum = 2;
set(gcf,'CurrentAxes',h(axnum));
plot(timecnt,R(day1:end),'k')
xlabel('Time (years)','FontSize',label_size)
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size,'xticklabel',[],'yaxislocation','right')
ylabel({'subsoil','water (mm)'},'FontSize',label_size,'Rotation',-90,'Units','normalized')
ypos = get(get(gca,'YLabel'),'Position');
ypos(1) = ypos(1)+0.03;
set(get(gca,'YLabel'),'Position',ypos);

%grass biomass
%subplot(6,1,3)
axnum = 3;
set(gcf,'CurrentAxes',h(axnum));
plot(timecnt,G(day1:end),'k')
%xlabel('Time (years)','FontSize',label_size)
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size)
ylabel({'grass biomass','(tonnes)'},'FontSize',label_size)

%% Plot discrete model dynamics on last 3 subplots

%skip first few years in plot?
skipyears = 0;
%shift years of x-axis
shift_years = 500;

load(discr_model)

%setup calculations
skipshiftyears = shift_years+skipyears;
timecnt = skipshiftyears:endYr+shift_years;
year1 = skipyears+1;
totaltrees = sum(solvector(treesteps:end-notreelength,:)); %neglect very small seedlings
%0 to 1m in 500 yrs
%0-15cm, 15-30cm, 30-50cm, 50cm-1m
smalltrees = sum(solvector(treesteps:76*treesteps,:));
mediumtrees = sum(solvector(76*treesteps+1:151*treesteps,:));
largetrees = sum(solvector(151*treesteps+1:251*treesteps,:));
hugetrees = sum(solvector(251*treesteps+1:end-notreelength,:));
tba = [tbacalc;zeros(notreelength,1)]'*solvector;

%plot stem count, size demographics, and biomass

%stem count
%subplot(6,1,4)
axnum = 4;
set(gcf,'CurrentAxes',h(axnum));
plot(timecnt,totaltrees(year1:end),'k')
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size,'xticklabel',[])
ylabel('stem count','FontSize',label_size)
title('Long-term Tree Dynamics','FontSize',title_size)

%size demographics
%subplot(6,1,5)
axnum = 5;
set(gcf,'CurrentAxes',h(axnum));
% semilogy(timecnt,smalltrees(year1:end),'k',...
%     timecnt,mediumtrees(year1:end),'g',timecnt,largetrees(year1:end),...
%     'b',timecnt,hugetrees(year1:end),'r')
% set(gca,'FontSize',tick_size,'xticklabel',[],'YTick',[1 100 10000],'yaxislocation','right')
% ylim([1 10000])
hold on
plot(timecnt,smalltrees(year1:end),'Color',[0.5 0.5 0.5],'LineStyle',':')
plot(timecnt,mediumtrees(year1:end),'Color',[0.5 0.5 0.5],'LineStyle','-.')
plot(timecnt,largetrees(year1:end),'Color',[0.3 0.3 0.3],'LineStyle','--')
plot(timecnt,hugetrees(year1:end),'k')
set(gca,'FontSize',tick_size,'XMinorTick','off','xticklabel',[],...
    'yaxislocation','right','xGrid','off')
ylim([0 500])
set(gca,'YTick',[0 250 500],'YMinorTick','off','YGrid','off')
ylabel({'stem count','by diameter'},'FontSize',label_size,'Rotation',-90,'Units','normalized')
ypos = get(get(gca,'YLabel'),'Position');
ypos(1) = ypos(1)+0.03;
set(get(gca,'YLabel'),'Position',ypos);
xlim([skipshiftyears endYr+shift_years])
h_legend = legend('0-15cm','16-30cm','31-50cm','51cm-1m');
set(h_legend,'FontSize',legend_size)

%biomass
%subplot(6,1,6)
axnum = 6;
set(gcf,'CurrentAxes',h(axnum));
plot(timecnt,tba(year1:end),'k')
%title('TBA per year')
xlim([skipshiftyears endYr+shift_years])
ylim([0 18])
set(gca,'YTick',[0 6 12 18],'FontSize',tick_size,'YMinorTick','on')
ylabel({'TBA','(m^2 ha^{-1})'},'FontSize',label_size)


%% Resposition lower subplots so that label xlabel has room
for axnum = 4:6
    axpos = get(h(axnum),'Position');
    axpos(2) = axpos(2)+0.02;
    set(h(axnum),'Position',axpos)
end
set(gcf,'CurrentAxes',h(6))
xlh = xlabel('Time (years)','FontSize',label_size);
pos1 = get(xlh,'Position');
pos1(1,2) = -3;
set(xlh,'Position',pos1)

%% Label each subplot
labelvec = ['a','b','c','d','e','f'];
for ii=1:6
    set(gcf,'CurrentAxes',h(ii));
    text(0.004,0.9,labelvec(ii),'Units','Normalized','FontSize',title_size,'FontWeight','bold')
end

%% Make the figure appear in the correct size, small margins
margins = 0.25;
width = 10.5;
height = 8;
shiftright = 0.25;
%on screen positioning and size
set(gcf,'Units','inches','Position',[0,0.5,width,0.5+height])
set(gcf,'PaperOrientation','landscape','PaperUnits','inches',...
    'PaperPosition',[margins,margins,width+shiftright,height],...
    'PaperSize',[width+margins*2,height+margins*2])
end