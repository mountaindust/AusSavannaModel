%% View data from .mat parameter sweeps
location_array = {'Darwin','Katherine','Sydney'};
eqTBAvals = [13.1, 10.5, 24.7];
label_size = 16;
tick_size = 14;
legend_size = 12.6;
title_size = 24;

for loc = 1:length(location_array)
    load([location_array{loc} '_long']) %drystart, dryend, drydays, juvsurv, total_tba
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

    %plot seedling event prob., stress prob., mean number of dry days
    figure(1)
    subplot(2,1,1)
    set(gca,'FontSize',tick_size)
    hold on
    if loc == 1
        l1 = plot(total_tba,nostressprob,'k');
        sl1 = plot(total_tba,juvsurvprob,'Color',[0.7 0.7 0.7]);
        sc1 = scatter(eqTBAvals(loc),...
            nostressprob(round(eqTBAvals(loc)/(total_tba(2)-total_tba(1)))),...
            50,'k','*');
    elseif loc == 2
        l2 = plot(total_tba,nostressprob,'LineStyle','--','Color','k');
        sl2 = plot(total_tba,juvsurvprob,'LineStyle','--','Color',[0.7 0.7 0.7]);
        scatter(eqTBAvals(loc),...
            nostressprob(round(eqTBAvals(loc)/(total_tba(2)-total_tba(1)))),...
            50,'k','*')
    else
        l3 = plot(total_tba,nostressprob,'-.','Color','k');
        sl3 = plot(total_tba,juvsurvprob,'LineStyle','-.','Color',[0.7 0.7 0.7]);
        scatter(eqTBAvals(loc),...
            nostressprob(round(eqTBAvals(loc)/(total_tba(2)-total_tba(1)))),...
            50,'k','*')
        legend([l1 sl1 l2 sl2 l3 sl3 sc1],...
            {[location_array{1} ' zero tree stress'],...
            [location_array{1} ' seedling survival'],...
            [location_array{2} ' zero tree stress'],...
            [location_array{2} ' seedling survival'],...
            [location_array{3} ' zero tree stress'],...
            [location_array{3} ' seedling survival'],...
            'Predicted climatic equilibrium'},...
            'Location','southeast','FontSize',legend_size);
        ylabel('Probability','FontSize',label_size)
        title('Probabilities by Total Basal Area','FontSize',title_size)
    end
    ylim([0 1]);
    xlabel('TBA m^2/ha','FontSize',label_size)
    hold off
    subplot(2,1,2)
    set(gca,'FontSize',tick_size)
    hold on
    if loc == 1
        mdry = mean(drydays);
        d1 = plot(total_tba,mdry,'k');
        scd1 = scatter(eqTBAvals(loc),...
            mdry(round(eqTBAvals(loc)/(total_tba(2)-total_tba(1)))),...
            50,'k','*');
    elseif loc == 2
        mdry = mean(drydays);
        d2 = plot(total_tba,mdry,'LineStyle','--','Color','k');
        scatter(eqTBAvals(loc),...
            mdry(round(eqTBAvals(loc)/(total_tba(2)-total_tba(1)))),...
            50,'k','*');
    else
        mdry = mean(drydays);
        d3 = plot(total_tba,mean(drydays),'LineStyle','-.','Color','k');
        scatter(eqTBAvals(loc),...
            mdry(round(eqTBAvals(loc)/(total_tba(2)-total_tba(1)))),...
            50,'k','*');
        legend([d1,d2,d3,scd1],{location_array{1},location_array{2},location_array{3},...
            'Predicted climatic equilibrium'},...
            'Location','northwest','FontSize',legend_size);
        xlabel('TBA m^2/ha','FontSize',label_size)
        ylabel('Mean # of dry days','FontSize',label_size)
        title('Mean number of dry days by Total Basal Area','FontSize',title_size)
    end
    hold off
    
end

%% Make the figure appear in the correct size, small margins
marginx = -0.5;
marginy = 0;
width = 12;
height = 8.5;
%on screen positioning and size
set(gcf,'Units','inches','Position',[0,0.5,width,0.5+height])
%positioning on paper
set(gcf,'PaperOrientation','landscape','PaperUnits','inches',...
    'PaperPosition',[marginx,marginy,width,height],...
    'PaperSize',[11,8.5])

%% View detailed data from .mat parameter sweep
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

% subplot(3,1,1)
% plot(total_tba,juvsurvprob)
% xlabel('Total TBA')
% ylabel('Seedling surv. prob.')
% title(['Probabilities by TBA for ' location])
% subplot(3,1,2)
% plot(total_tba,nostressprob)
% xlabel('Total TBA')
% ylabel('No tree stress prob.')
% subplot(3,1,3)
% plot(total_tba,mean(drydays))
% xlabel('Total TBA')
% ylabel('Mean # of dry days')

label_size = 16;
tick_size = 14;
legend_size = 12.6;
title_size = 24;

while 1
    tbain = input(['Plot distribution for tba value, ' num2str(total_tba(1)) ...
        '-' num2str(total_tba(end)) ', or q to quit:'],'s');
    tbain = strtrim(tbain);
    if isempty(tbain)
        continue
    elseif strcmp(tbain,'q') || strcmp(tbain,'Q')
        break
    else
        tba = str2double(tbain);
        if isempty(tba)
            disp('Invalid input')
            continue
        elseif mod(tba,total_tba(2)-total_tba(1)) ~= 0
            disp('tba must be a multiple of 0.1')
            continue
        else
            param = round(tba/(total_tba(2)-total_tba(1)));
            
            figure
            %length of dry
            subplot(3,1,1)
            histogram(dryend(:,param)-drystart(:,param),...
                min(dryend(:,param)-drystart(:,param)):max(dryend(:,param)-drystart(:,param)),...
                'Normalization','probability','FaceColor','k')
            set(gca,'FontSize',tick_size)
            xlabel('Days in dry season','FontSize',label_size)
            ylabel('Probability','FontSize',label_size)
            title(['Dry season length for ' location ' when TBA = ' num2str(tba) ...
                ' m^2 ha^{-1}'],'FontSize',title_size)
            xlim([120 365])
            h = findobj(gca,'Type','patch');
            set(h,'FaceColor','k','EdgeColor','k')
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
                title('Distribution of non-zero tree stress days','FontSize',title_size)
                text(0.02,0.92,['Probability of zero stress: ' ...
                    num2str(round(nondrycnt/length(dryend(:,param)),2))],...
                    'FontSize',label_size,'Units','normalized')
                text(0.74,0.92,['Seedling probability: ' ...
                    num2str(round(sum(juvsurv(:,param))/length(juvsurv(:,param)),2))],...
                    'FontSize',label_size,'Units','normalized')
                h = findobj(gca,'Type','patch');
                set(h,'FaceColor','k','EdgeColor','w')
            else
                set(gca,'FontSize',tick_size)
                xlabel('Number of soil dry days','FontSize',label_size)
                ylabel('Probability','FontSize',label_size)
                title('Trees are not under stress','FontSize',title_size)
                text(0.02,0.92,['Probability of zero stress: ' ...
                    num2str(round(nondrycnt/length(dryend(:,param)),2))],...
                    'FontSize',label_size,'Units','normalized')
                text(0.70,0.92,['Seedling probability: ' ...
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
            title(['Dry start/end distribution for ' location ' when TBA = ' ...
                num2str(tba) ' m^2 ha^{-1}'],'FontSize',title_size)
            legend({'Start','End'},'Location','north')
            hold off
            
            % Make the figure appear in the correct size, small margins
            marginx = -0.5;
            marginy = 0;
            width = 12;
            height = 8.5;
            %on screen positioning and size
            set(gcf,'Units','inches','Position',[0,0.5,width,0.5+height])
            %positioning on paper
            set(gcf,'PaperOrientation','landscape','PaperUnits','inches',...
                'PaperPosition',[marginx,marginy,width,height],...
                'PaperSize',[11,8.5])

            disp(['Probability of seedlings with TBA=' num2str(tba) ': ',...
                num2str(sum(juvsurv(:,param))/length(juvsurv(:,param)))])
        end
    end
end