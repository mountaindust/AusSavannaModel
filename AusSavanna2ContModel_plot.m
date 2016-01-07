%Plot solution from continuous model

function AusSavanna2ContModel_plot(varargin)

%skip first few years in plot?
skipyears = 0;
%shift years of x-axis
shift_years = 0;

if nargin == 1,
    load(varargin{1})
else
    Gam = varargin{1};
    R = varargin{2};
    G = varargin{3};
    Vgf = varargin{4};
    Vg = varargin{5};
    VR = varargin{6};
    endYr = varargin{7};
    solvector = varargin{8};
    treesteps = varargin{9};
    tbacalc = varargin{10};
end

%quick font sizes
title_size = 32;
tick_size = 14;
label_size = 24;
legend_size = 14;
%quick label offsets
ldx = 80;
ldy = 12;

%% Plot water and grass dynamics
skipshiftyears = shift_years+skipyears;
timecnt = linspace(skipshiftyears,endYr+shift_years,(endYr-skipyears)*365+1); %units are years
day1 = 1+skipyears*365;

figure

%topsoil water
subplot(3,1,1)
plot(timecnt,Gam(day1:end),'r')
c1 = axes_label('a',ldx,ldy);
title(['Water in topsoil, F_\Gamma = ' num2str(Vgf) ', V_\Gamma = ' ...
    num2str(Vg)],'FontSize',title_size)
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size)
ylabel({'topsoil','water (mm)'},'FontSize',label_size)

%subsoil water
subplot(3,1,2)
plot(timecnt,R(day1:end),'b')
c2 = axes_label('b',ldx,ldy);
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size)
title(['Water in subsoil, V_R = ' num2str(VR)],'FontSize',title_size)
ylabel({'subsoil','water (mm)'},'FontSize',label_size)

%grass biomass
subplot(3,1,3)
plot(timecnt,G(day1:end),'g')
c3 = axes_label('c',ldx,ldy);
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size)
title('Grass biomass','FontSize',title_size)
xlabel('Time (years)')
ylabel({'grass','biomass','(tonnes)'},'FontSize',label_size)

%% Plot tree dynamics

%setup calculations
skipshiftyears = shift_years+skipyears;
timecnt = linspace(skipshiftyears,endYr+shift_years,(endYr-skipyears)*12+1); %units are years
month1 = skipyears*12+1;

totaltrees = sum(solvector(treesteps:end,:)); %neglect very small seedlings
%0 to 1m in 500 yrs
%0-15cm, 15-30cm, 30-50cm, 50cm-1m
smalltrees = sum(solvector(treesteps:76*treesteps,:));
mediumtrees = sum(solvector(76*treesteps+1:151*treesteps,:));
largetrees = sum(solvector(151*treesteps+1:251*treesteps,:));
hugetrees = sum(solvector(251*treesteps+1:end,:));
tba = tbacalc'*solvector;

figure

%stem count
subplot(3,1,1)
plot(timecnt,totaltrees(month1:end))
c4 = axes_label('a',ldx,ldy);
xlim([skipshiftyears endYr+shift_years])
set(gca,'FontSize',tick_size)
ylabel('stem count','FontSize',label_size)
title('Tree dynamics','FontSize',title_size)

%size demographics
subplot(3,1,2)
% semilogy(timecnt,smalltrees(month1:end),'k',...
%     timecnt,mediumtrees(month1:end),'g',timecnt,largetrees(month1:end),...
%     'b',timecnt,hugetrees(month1:end),'r')
% set(gca,'FontSize',tick_size,'YTick',[1 10 100 1000 10000])
% xlim([skipshiftyears endYr+shift_years])
% ylim([1 10000])
plot(timecnt,smalltrees(month1:end),'k',...
    timecnt,mediumtrees(month1:end),'g',timecnt,largetrees(month1:end),'b',...
    timecnt,hugetrees(month1:end),'r')
set(gca,'FontSize',tick_size)
ylim([0 500])
c5 = axes_label('b',ldx,ldy);
ylabel({'stem count','by','diameter'},'FontSize',label_size)
h_legend = legend('0-15cm','16-30cm','31-50cm','51cm-1m');
set(h_legend,'FontSize',legend_size)

%biomass
subplot(3,1,3)
plot(timecnt,tba(month1:end))
c6 = axes_label('c',ldx,ldy);
xlabel('Time (years)','FontSize',label_size)
xlim([skipshiftyears endYr+shift_years])
ylabel({'TBA','(m^2 ha^{-1})'},'FontSize',label_size)
set(gca,'FontSize',tick_size)

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