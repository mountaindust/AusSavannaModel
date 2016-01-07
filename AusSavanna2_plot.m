%Plot solution from discrete-time model

function AusSavanna2_plot(varargin)

%skip first few years in plot?
skipyears = 500;
%shift years of x-axis
shift_years = 0;

if nargin == 1,
    load(varargin{1})
else
    endYr = varargin{1};
    solvector = varargin{2};
    treesteps = varargin{3};
    notreelength = varargin{4};
    tbacalc = varargin{5};
    sizeclslength = varargin{6};
    monthlyLiveGrass = varargin{7};
    monthlyDeadGrass = varargin{8};
end

%% Plot tree dynamics

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

%quick font sizes
title_size = 24;
tick_size = 14;
label_size = 16;
legend_size = 12.6;
%quick label offsets
ldx = 80;
ldy = 12;

figure
%stem count
subplot(3,1,1)
plot(timecnt,totaltrees(year1:end),'k')
c1 = axes_label('a',ldx,ldy);
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size)
ylabel('stem count','FontSize',label_size)
%title for the collection of plots
title('Long-term Tree Dynamics','FontSize',title_size)

subplot(3,1,2)
%size demographics
% semilogy(timecnt,smalltrees(year1:end),'k',...
%     timecnt,mediumtrees(year1:end),'g',timecnt,largetrees(year1:end),'b',...
%     timecnt,hugetrees(year1:end),'r')
%set(gca,'FontSize',tick_size,'YTick',[1 10 100 1000 10000])
%ylim([1 10000])
plot(timecnt,smalltrees(year1:end),'k',...
    timecnt,mediumtrees(year1:end),'g',timecnt,largetrees(year1:end),'b',...
    timecnt,hugetrees(year1:end),'r')
set(gca,'FontSize',tick_size)
ylim([0 500])
c2 = axes_label('b',ldx,ldy);
%title('Trees by size (diameter)')
xlim([skipshiftyears endYr+shift_years])

ylabel({'stem count','by diameter'},'FontSize',label_size)
h_legend = legend('0-15cm','16-30cm','31-50cm','51cm-1m');
set(h_legend,'FontSize',legend_size)

subplot(3,1,3)
%biomass
plot(timecnt,tba(year1:end),'Color',[0, 0.6, 0])
c3 = axes_label('c',ldx,ldy);
%title('TBA per year')
xlabel('Time (years)','FontSize',label_size)
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size)
ylabel({'TBA','(m^2 ha^{-1})'},'FontSize',label_size)


%% Plot Grass/Litter dynamics
% slowtimecnt = 1/12:1/12:endYr;
% 
% figure
% %Tree litter
% subplot(3,1,1)
% plot(timecnt,solvector(sizeclslength+1,:))
% title('Tree Litter')
% xlabel('Year')
% ylabel('tons')
% 
% subplot(3,1,2)
% %Live grass
% plot(slowtimecnt,monthlyLiveGrass)
% title('Live Grass')
% xlabel('Year')
% ylabel('tons')
% 
% subplot(3,1,3)
% %Dead grass
% plot(slowtimecnt,monthlyDeadGrass)
% title('Dead Grass')
% xlabel('Year')
% ylabel('tons')

end

%% Supporting functions

%These functions are for labeling subplots (found on stackoverflow.com,
%posted by jmlopez 8/20/2015

%   c = axes_label('label')
%      Places the text object with the string 'label' on the upper-left 
%      corner of the current axes and returns a cell containing the handle
%      of the text and an event listener.
%
%   c = axes_label('label', dx, dy)
%      Places the text object dx pixels from the left side of the axes
%      and dy pixels from the top. These values are set to 3 by default.
%
%   c = axes_label(c, ...)
%      Peforms the operations mentioned above on cell c containing the
%      handle of the text and the event listener.
%
%   c = axes_label(c, dx, dy)
%      Adjusts the current label to the specifed distance from the
%      upper-left corner of the current axes.

function c = axes_label(varargin)

if isa(varargin{1}, 'char')
    axesHandle = gca;
else
    axesHandle = get(varargin{1}{1}, 'Parent');
end

if strcmp(get(get(axesHandle, 'Title'), 'String'), '')
    title(axesHandle, ' ');
end
if strcmp(get(get(axesHandle, 'YLabel'), 'String'), '')
    ylabel(axesHandle, ' ');
end
if strcmp(get(get(axesHandle, 'ZLabel'), 'String'), '')
    zlabel(axesHandle, ' ');
end

if isa(varargin{1}, 'char')    
    label = varargin{1};
    if nargin >=2
        dx = varargin{2};
        if nargin >= 3
            dy = varargin{3};
        else
            dy = 0;
        end
    else
        dx = 3;
        dy = 3;
    end
    h = text('String', label, ...
        'HorizontalAlignment', 'left',...
        'VerticalAlignment', 'top', ...
        'FontUnits', 'pixels', ...
        'FontSize', 32, ...
        'FontWeight', 'bold', ...
        'FontName', 'Arial', ...
        'Units', 'normalized');
    el = addlistener(axesHandle, 'Position', 'PostSet', @(o, e) posChanged(o, e, h, dx, dy));
    c = {h, el};
else
    h = varargin{1}{1};
    delete(varargin{1}{2});
    if nargin >= 2    
        if isa(varargin{2}, 'char')
            set(h, 'String', varargin{2});
            if nargin >=3
                dx = varargin{3};
                dy = varargin{4};
            else
                dx = 3;
                dy = 3;
            end
        else
            dx = varargin{2};
            dy = varargin{3};
        end
    else
       error('Needs more arguments. Type help axes_label'); 
    end
    el = addlistener(axesHandle, 'Position', 'PostSet', @(o, e) posChanged(o, e, h, dx, dy));
    c = {h, el};
end
posChanged(0, 0, h, dx, dy);
end

function posChanged(~, ~, h, dx, dy)
    axh = get(h, 'Parent');
    p = get(axh, 'Position');
    o = get(axh, 'OuterPosition');
    xp = (o(1)-p(1))/p(3);
    yp = (o(2)-p(2)+o(4))/p(4);
    set(h, 'Units', get(axh, 'Units'),'Position', [xp yp]);
    set(h, 'Units', 'pixels');
    p = get(h, 'Position');
    set(h, 'Position', [p(1)+dx, p(2)+5-dy]);
    set(h, 'Units', 'normalized');
end