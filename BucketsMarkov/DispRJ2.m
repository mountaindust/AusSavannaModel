%Last two plots to combine into BWClimate

location_array = {'Darwin','Katherine','Sydney'};
eqTBAvals = [13.1, 10.5, 24.7];
label_size = 16;
tick_size = 14;
legend_size = 11.6;
title_size = 18;

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
        title('Survival and Stress by Total Basal Area','FontSize',title_size)
    end
    ylim([0 1]);
    %xlabel('TBA m^2/ha','FontSize',label_size)
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
    end
    hold off
    
end

%% Make the figure appear in the correct size, small margins
marginx = -0.25;
marginy = 6.5;
width = 9.25;
height = 4.5;
%on screen positioning and size
set(gcf,'Units','inches','Position',[0,0.5,width,0.5+height])
%positioning on paper
set(gcf,'PaperOrientation','portrait','PaperUnits','inches',...
    'PaperPosition',[marginx,marginy,width,height],...
    'PaperSize',[8.5,11])