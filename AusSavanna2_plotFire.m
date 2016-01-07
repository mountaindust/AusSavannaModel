function AusSavanna2_plotFire(fire_1,fire_2,fire_3)

%quick font sizes
title_size = 19;
tick_size = 14;
label_size = 16;
legend_size = 11;

figure

%subplot layout
C = {{{['-g']};{['-g']}};{{['-g']};{['-g']}};{{['-g']};{['-g']}}};
[h,labelfontsize] = subplotplus(C2);

%Global skip and shift years settings

%skip first few years in plot?
skipyears = 500;
%shift years of x-axis
shift_years = 0;

skipshiftyears = shift_years+skipyears;
year1 = skipyears+1;

%% First set
load(fire_1)
timecnt = skipshiftyears:endYr+shift_years;
totaltrees = sum(solvector(treesteps:end-notreelength,:)); %neglect very small seedlings
%0 to 1m in 500 yrs
%0-15cm, 15-30cm, 30-50cm, 50cm-1m
smalltrees = sum(solvector(treesteps:76*treesteps,:));
mediumtrees = sum(solvector(76*treesteps+1:151*treesteps,:));
largetrees = sum(solvector(151*treesteps+1:251*treesteps,:));
hugetrees = sum(solvector(251*treesteps+1:end-notreelength,:));
tba = [tbacalc;zeros(notreelength,1)]'*solvector;

%plot size demographics and biomass

%size demographics
axnum = 1;
set(gcf,'CurrentAxes',h(axnum));
% semilogy(timecnt,smalltrees(year1:end),'k',...
%     timecnt,mediumtrees(year1:end),'g',timecnt,largetrees(year1:end),...
%     'b',timecnt,hugetrees(year1:end),'r')
% set(gca,'FontSize',tick_size,'xticklabel',[],'YTick',[1 100 10000],'yaxislocation','right')
% ylim([1 10000])
hold on
plot(timecnt,smalltrees(year1:end),'Color',[0.30 0.67 0.15],'LineStyle',':')
plot(timecnt,mediumtrees(year1:end),'Color',[0.58 0.71 0.42],'LineStyle','-.')
plot(timecnt,largetrees(year1:end),'Color',[0.70 0.61 0.39],'LineStyle','--')
plot(timecnt,hugetrees(year1:end),'Color',[0.65 0.38 0.10])
ylim([0 500])
set(gca,'FontSize',tick_size,'ytick',[0 250 500],'xticklabel',[],...
    'XMinorTick','off','YMinorTick','off','XGrid','off','YGrid','off')
ylabel({'stem count','by diameter'},'FontSize',label_size)
xlim([skipshiftyears endYr+shift_years])
h_legend = legend('0-15cm','16-30cm','31-50cm','51cm-1m');
set(h_legend,'FontSize',legend_size)
title('Fire Every 4 Years in July','FontSize',title_size)
hold off

%biomass
axnum = 2;
set(gcf,'CurrentAxes',h(axnum));
plot(timecnt,tba(year1:end),'Color',[0 0.39 0])
xlim([skipshiftyears endYr+shift_years])
ylim([0 15])
xticks = get(gca,'XTickLabel');
if mod(length(xticks),2) == 1
    xticks{ceil(length(xticks)/2)} = '';
else
    xticks{length(xticks)/2} = '';
    xticks{length(xticks)/2+1} = '';
end
set(gca,'FontSize',tick_size,'yaxislocation','right','YGrid','on','xticklabel',xticks)
ylabel({'TBA','(m^2 ha^{-1})'},'FontSize',label_size,'Rotation',-90,'Units','normalized')
ypos = get(get(gca,'YLabel'),'Position');
ypos(1) = ypos(1)+0.05;
set(get(gca,'YLabel'),'Position',ypos);

%% Second set
load(fire_2)
timecnt = skipshiftyears:endYr+shift_years;
totaltrees = sum(solvector(treesteps:end-notreelength,:)); %neglect very small seedlings
%0 to 1m in 500 yrs
%0-15cm, 15-30cm, 30-50cm, 50cm-1m
smalltrees = sum(solvector(treesteps:76*treesteps,:));
mediumtrees = sum(solvector(76*treesteps+1:151*treesteps,:));
largetrees = sum(solvector(151*treesteps+1:251*treesteps,:));
hugetrees = sum(solvector(251*treesteps+1:end-notreelength,:));
tba = [tbacalc;zeros(notreelength,1)]'*solvector;

%size demographics
axnum = 3;
set(gcf,'CurrentAxes',h(axnum));
% semilogy(timecnt,smalltrees(year1:end),'k',...
%     timecnt,mediumtrees(year1:end),'g',timecnt,largetrees(year1:end),...
%     'b',timecnt,hugetrees(year1:end),'r')
% set(gca,'FontSize',tick_size,'xticklabel',[],'YTick',[1 100 10000],'yaxislocation','right')
% ylim([1 10000])
hold on
plot(timecnt,smalltrees(year1:end),'Color',[0.30 0.67 0.15],'LineStyle',':')
plot(timecnt,mediumtrees(year1:end),'Color',[0.58 0.71 0.42],'LineStyle','-.')
plot(timecnt,largetrees(year1:end),'Color',[0.70 0.61 0.39],'LineStyle','--')
plot(timecnt,hugetrees(year1:end),'Color',[0.65 0.38 0.10])
ylim([0 500])
set(gca,'FontSize',tick_size,'xticklabel',[],'ytick',[0 250 500],...
    'XMinorTick','off','YMinorTick','off','XGrid','off','YGrid','off')
ylabel({'stem count','by diameter'},'FontSize',label_size)
xlim([skipshiftyears endYr+shift_years])
h_legend = legend('0-15cm','16-30cm','31-50cm','51cm-1m');
set(h_legend,'FontSize',legend_size)
title('Fire in July with 0.25 Probability','FontSize',title_size)
hold off

%biomass
axnum = 4;
set(gcf,'CurrentAxes',h(axnum));
plot(timecnt,tba(year1:end),'Color',[0 0.39 0])
xlim([skipshiftyears endYr+shift_years])
ylim([0 18])
set(gca,'YTick',[0 6 12 18])
xticks = get(gca,'XTickLabel');
if mod(length(xticks),2) == 1
    xticks{ceil(length(xticks)/2)} = '';
else
    xticks{length(xticks)/2} = '';
    xticks{length(xticks)/2+1} = '';
end
set(gca,'FontSize',tick_size,'yaxislocation','right','YGrid','on',...
    'xticklabel',xticks,'YMinorTick','on')
ylabel({'TBA','(m^2 ha^{-1})'},'FontSize',label_size,'Rotation',-90,'Units','normalized')
ypos = get(get(gca,'YLabel'),'Position');
ypos(1) = ypos(1)+0.05;
set(get(gca,'YLabel'),'Position',ypos);

%% Third set
load(fire_3)
timecnt = skipshiftyears:endYr+shift_years;
totaltrees = sum(solvector(treesteps:end-notreelength,:)); %neglect very small seedlings
%0 to 1m in 500 yrs
%0-15cm, 15-30cm, 30-50cm, 50cm-1m
smalltrees = sum(solvector(treesteps:76*treesteps,:));
mediumtrees = sum(solvector(76*treesteps+1:151*treesteps,:));
largetrees = sum(solvector(151*treesteps+1:251*treesteps,:));
hugetrees = sum(solvector(251*treesteps+1:end-notreelength,:));
tba = [tbacalc;zeros(notreelength,1)]'*solvector;

%size demographics
axnum = 5;
set(gcf,'CurrentAxes',h(axnum));
% semilogy(timecnt,smalltrees(year1:end),'k',...
%     timecnt,mediumtrees(year1:end),'g',timecnt,largetrees(year1:end),...
%     'b',timecnt,hugetrees(year1:end),'r')
% set(gca,'FontSize',tick_size,'xticklabel',[],'YTick',[1 100 10000],'yaxislocation','right')
% ylim([1 10000])
hold on
plot(timecnt,smalltrees(year1:end),'Color',[0.30 0.67 0.15],'LineStyle',':')
plot(timecnt,mediumtrees(year1:end),'Color',[0.58 0.71 0.42],'LineStyle','-.')
plot(timecnt,largetrees(year1:end),'Color',[0.70 0.61 0.39],'LineStyle','--')
plot(timecnt,hugetrees(year1:end),'Color',[0.65 0.38 0.10])
ylim([0 500])
set(gca,'FontSize',tick_size,'xticklabel',[],'ytick',[0 250 500],...
    'XMinorTick','off','YMinorTick','off','XGrid','off','YGrid','off')
ylabel({'stem count','by diameter'},'FontSize',label_size)
xlim([skipshiftyears endYr+shift_years])
h_legend = legend('0-15cm','16-30cm','31-50cm','51cm-1m');
set(h_legend,'FontSize',legend_size)
%title('Fire with Monthly Prob. 0.05 (when fuel present)','FontSize',title_size)
title('Random Fire May-Nov. with Yearly Prob. 0.33','FontSize',title_size)
hold off

%biomass
axnum = 6;
set(gcf,'CurrentAxes',h(axnum));
plot(timecnt,tba(year1:end),'Color',[0 0.39 0])
xlim([skipshiftyears endYr+shift_years])
ylim([0 18])
set(gca,'YTick',[0 6 12 18])
set(gca,'FontSize',tick_size,'yaxislocation','right','YGrid','on','YMinorTick','on')
ylabel({'TBA','(m^2 ha^{-1})'},'FontSize',label_size,'Rotation',-90,'Units','normalized')
ypos = get(get(gca,'YLabel'),'Position');
ypos(1) = ypos(1)+0.05;
set(get(gca,'YLabel'),'Position',ypos);
%xlabel('Time (years)','FontSize',label_size)

%% Resposition lower subplots so that label xlabel has room
for axnum = 3:4
    axpos = get(h(axnum),'Position');
    axpos(2) = axpos(2)+0.02;
    set(h(axnum),'Position',axpos)
end
for axnum = 5:6
    axpos = get(h(axnum),'Position');
    axpos(2) = axpos(2)+0.04;
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
