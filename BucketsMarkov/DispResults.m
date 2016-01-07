%View data from .mat parameter sweeps
location = 'Darwin';

load([location '_long.mat']) %drystart, dryend, drydays, juvsurv, total_tba
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
figure
subplot(2,1,1)
hold on
plot(total_tba,juvsurvprob,'g')
plot(total_tba,nostressprob,'b')
ylim([0 1]);
ylabel('Probability')
title(['Probabilities by TBA for ' location])
legend('Seedling survival','Zero tree stress')
hold off
subplot(2,1,2)
hold on
plot(total_tba,mean(drydays),'k')
xlabel('TBA m^2/ha')
ylabel('Mean # of dry days')
title(['Mean number of dry days by TBA for ' location])
hold off

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

while 1
    tbain = input('Plot distribution for tba value, 0.1-20, or q to quit:','s');
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
        elseif mod(tba,0.1) ~= 0
            disp('tba must be a multiple of 0.1')
            continue
        else
            param = round(tba/0.1);
            
            figure
            %beginning of dry
            hist(drystart(:,param),1:365)
            hold on
            %end of dry
            hist(dryend(:,param),1:max(dryend(:,param)))
            xlabel('Day of year')
            ylabel('Frequency')
            title(['Dry start/end distribution for ' location ', TBA = ' ...
                num2str(tba) ' m^2 ha^{-1}'])
            h = findobj(gca,'Type','patch');
            %beginning of dry = green, end = brown
            set(h(2),'FaceColor','g','EdgeColor','g')
            set(h(1),'FaceColor',[.6 .4 0],'EdgeColor',[.6 .4 0])
            legend('Start','End')
            hold off
            
            figure
            %length of dry
            subplot(2,1,1)
            hist(dryend(:,param)-drystart(:,param),...
                min(dryend(:,param)-drystart(:,param)):max(dryend(:,param)-drystart(:,param)))
            xlabel('Length of dry season')
            ylabel('Frequency')
            title(['Dry season length for ' location ', TBA = ' num2str(tba) ...
                ' m^2 ha^{-1}'])
            xlim([0 365])
            h = findobj(gca,'Type','patch');
            set(h,'EdgeColor','k')
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
            subplot(2,1,2)
            if ~isempty(dryonly)
                hist(dryonly,1:max(dryonly))
                xlabel('Number of soil dry days')
                ylabel('Frequency')
                title(['Non-zero tree stress days ploted. Zero stress days proability: ' ...
                    num2str(nondrycnt/length(juvsurv(:,param))) '%. Seedling probability: ' ...
                    num2str(100*sum(juvsurv(:,param))/length(juvsurv(:,param))) ...
                    '%'])
            else
                title(['Zero stress days probability: 100%. Seedling probability: ' ...
                    num2str(100*sum(juvsurv(:,param))/length(juvsurv(:,param))) ...
                    '%'])
            end

            disp(['Probability of seedlings with TBA=' num2str(tba) ': ',...
                num2str(sum(juvsurv(:,param))/length(juvsurv(:,param)))])
        end
    end
end