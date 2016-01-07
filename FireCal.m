classdef FireCal < handle
    properties (SetAccess = private)
        StocFlag
        FireFrequency
        MonthOfBurn
        MonthsOfBurn
        Month
        Year
        waittime
    end
    
    methods
        function FC = FireCal(StocFlag, FireFrequency, MonthOfBurn) 
        %MonthOfBurn = 0 - any month.
        %MonthOfBurn = vector - if fire occurs, equal prob. among months in vector
        %                       StocFlag=1 here specifies per year prob.
        %Stocastically, FireFreq is a prob per month (or prob per year if the month of
        %burn is specified)
            FC.StocFlag = StocFlag;
            FC.FireFrequency = FireFrequency;
            if length(MonthOfBurn) == 1
                FC.MonthOfBurn = MonthOfBurn;
                FC.MonthsOfBurn = 0;
            else
                FC.MonthsOfBurn = MonthOfBurn;
                FC.SetNewMonthOfBurn %ensures FC.MonthOfBurn ~= 0 and picks first month if StocFlag==0
            end
            if StocFlag == 1,
                FC.SetNewFireDate(1,1);
            end
        end
        
        function IsFireFlag = IsFire(FC, month, year)
            if FC.StocFlag == 0, %check to see if we are in the specified month/year
                if FC.FireFrequency > 0,
                    if year/FC.FireFrequency == round(year/FC.FireFrequency) && month == FC.MonthOfBurn,
                        IsFireFlag = 1;
                        if length(FC.MonthsOfBurn)>1
                            FC.SetNewMonthOfBurn
                        end
                    else
                        IsFireFlag = 0;
                    end 
                else
                    IsFireFlag = 0;
                end
            elseif FC.StocFlag == 1, 
                %check to see if we are in the specified month/year
                %If yes, there is a fire, plus get the date of the next fire
                if year == FC.Year && month == FC.Month,
                    IsFireFlag = 1;
                    FC.SetNewFireDate(month,year);
                else
                    IsFireFlag = 0;
                end
            end
        end
        
        function SetNewFireDate(FC, month, year)
            %roll forward in time until there is a fire - record that date
            if FC.FireFrequency ~= 0,
                suc = 0;
                FC.waittime = 0;
                while suc == 0,
                    FC.waittime = FC.waittime + 1;
                    if rand(1,1) <= FC.FireFrequency,
                        suc = 1;
                    end
                end
                if FC.MonthOfBurn == 0,
                    %probability was monthly
                    FC.Year = year + floor((month + FC.waittime)/12);
                    FC.Month = mod(month + FC.waittime,12)+1;
                    return
                elseif length(FC.MonthsOfBurn) == 1
                    %probability was yearly with month specified
                    FC.Year = year + FC.waittime;
                    FC.Month = FC.MonthOfBurn;
                    return
                else
                    %probability was yearly with several months specified
                    FC.Year = year + FC.waittime;
                    FC.Month = FC.MonthsOfBurn(randi(length(FC.MonthsOfBurn)));
                end
            end
        end
        
        function SetNewMonthOfBurn(FC)
            %use when month of burn is given as a vector
            %stochastically choose a month of burn from those listed
            FC.MonthOfBurn = FC.MonthsOfBurn(randi(length(FC.MonthsOfBurn)));
        end
    end
end