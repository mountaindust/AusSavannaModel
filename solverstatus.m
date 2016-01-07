%function to report status of ode solver
function status = solverstatus(t,y,flag)

status = 0; %don't stop solver
global steptimer
global totaltimer

if strcmp(flag,'init'), %initialization
    c = fix(clock);
    disp(['ODE solver started on ', num2str(c(2)),'/',num2str(c(3)),' at ',...
        num2str(c(4)),':',num2str(c(5)),':',num2str(c(6))])
    %fprintf('Vector length is %u\n',length(y))
    steptimer = tic;
    totaltimer = tic;
elseif strcmp(flag,'done'), %end
    disp('ODE solver has finished.')
    clear global steptimer
    disp('Total time:')
    toc(totaltimer)
else
%     c = fix(clock);
    disp('ODE solver has completed a time step, evaluating at time:')
    disp(t)
%     disp(['Current date and time is: ',num2str(c(2)),'/',num2str(c(3)),' at ',...
%         num2str(c(4)),':',num2str(c(5)),':',num2str(c(6))])
    toc(steptimer)
    steptimer = tic;
end