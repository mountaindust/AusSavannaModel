%First three plots to combine into BWClimate

%% View detailed data from .mat parameter sweep
label_size = 16;
tick_size = 14;
legend_size = 12.6;
title_size = 18;

tba = 13.1;

location = 'Darwin';

load([location '_long']) %drystart, dryend, drydays, juvsurv, total_tba
%each column represents a different parameter value

[numyrs,numruns] = size(drystart);

juvsurvprob = sum(juvsurv)/numyrs;
nostressprob = zeros(numruns,1);
for jj = 1:numruns,
    cnt = 0;
    for ii = 1:numyrs,
        if drydays(ii,jj) == 0
            cnt = cnt+1;
        end
    end
    nostressprob(jj) = cnt/numyrs;
end

param = round(tba/(total_tba(2)-total_tba(1)));

figure

%subplot layout

%length of dry
subplot(3,1,1)
histogram(dryend(:,param)-drystart(:,param),...
    min(dryend(:,param)-drystart(:,param)):max(dryend(:,param)-drystart(:,param)),...
    'Normalization','probability','FaceColor','k')
set(gca,'FontSize',tick_size)
xlabel('Days in dry season','FontSize',label_size);
ylabel('Probability','FontSize',label_size)
title('Dry Season Distributions with Fixed TBA','FontSize',title_size)
xlim([120 365])
hp = findobj(gca,'Type','patch');
set(hp,'FaceColor','k','EdgeColor','k')
%non-zero tree stress days
nondrycnt = 0;
dryonly = [];
for ii = 1:length(drydays(:,param))
    if drydays(ii,param) > 0
        dryonly = [dryonly; drydays(ii,param)];
    else
        nondrycnt = nondrycnt + 1;
    end
end

subplot(3,1,2)
if ~isempty(dryonly)
    histogram(dryonly,1:max(dryonly),'Normalization','probability',...
        'FaceColor','k')
    set(gca,'FontSize',tick_size)
    xlabel('Number of soil dry days','FontSize',label_size)
    ylabel('Probability','FontSize',label_size)
    text(0.02,0.90,['Probability of zero stress: ' ...
        num2str(round(nondrycnt/length(dryend(:,param)),2))],...
        'FontSize',label_size,'Units','normalized')
    text(0.72,0.90,['Seedling probability: ' ...
        num2str(round(sum(juvsurv(:,param))/length(juvsurv(:,param)),2))],...
        'FontSize',label_size,'Units','normalized')
    hp = findobj(gca,'Type','patch');
    set(hp,'FaceColor','k','EdgeColor','w')
else
    set(gca,'FontSize',tick_size)
    xlabel('Number of soil dry days','FontSize',label_size)
    ylabel('Probability','FontSize',label_size)
    text(0.02,0.90,['Probability of zero stress: ' ...
        num2str(round(nondrycnt/length(dryend(:,param)),2))],...
        'FontSize',label_size,'Units','normalized')
    text(0.72,0.90,['Seedling probability: ' ...
        num2str(round(sum(juvsurv(:,param))/length(juvsurv(:,param)),2))],...
        'FontSize',label_size,'Units','normalized')
end

subplot(3,1,3)
%beginning of dry
%beginning of dry = green, end = brown
histogram(drystart(:,param),1:365,'Normalization','probability',...
    'FaceColor','k','EdgeColor','k')
hold on
%end of dry
histogram(dryend(:,param),1:max(dryend(:,param)),...
    'Normalization','probability',...
    'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5])
set(gca,'FontSize',tick_size)
xlabel('Day of year','FontSize',label_size)
ylabel('Probability','FontSize',label_size)
legend({'Start','End'},'Location','north')
hold off

%% Make the figure appear in the correct size, small margins
marginx = -0.25;
marginy = 5.5;
width = 9.25;
height = 5.5;
%on screen positioning and size
set(gcf,'Units','inches','Position',[0,0.5,width,0.5+height])
%positioning on paper
set(gcf,'PaperOrientation','portrait','PaperUnits','inches',...
    'PaperPosition',[marginx,marginy,width,height],...
    'PaperSize',[8.5,11])