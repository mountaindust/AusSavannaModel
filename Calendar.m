classdef Calendar < handle
    properties (SetAccess = private)
        DaysInMonth = [31;28;31;30;31;30;31;31;30;31;30;31];
        NumberOfYears
        Year = 1;
        PrevYear = 1;
        Month = 1;
        PrevMonth = 0;
        DayOfMonth = 1;
        PrevDayOfMonth = 0;
        DayOfYear = 1;
        PrevDayOfYear = 0;
        Day = 1;%total
        EndFlag = 0;
        FirstDayFlag = 1;
    end
    
    methods
        function Cal = Calendar(NumberOfYears)
            Cal.NumberOfYears = NumberOfYears;
        end
        
        function nextDay(Cal)
            Cal.Day = Cal.Day + 1; %advance total count
            Cal.FirstDayFlag = 0; %turn off first day flag
            if Cal.DayOfYear == 365, %end of year check
                Cal.Year = Cal.Year + 1;
                Cal.PrevMonth = 12;
                Cal.Month = 1;
                Cal.PrevDayOfMonth = 31;
                Cal.DayOfMonth = 1;
                Cal.PrevDayOfYear = 365;
                Cal.DayOfYear = 1;
                if Cal.Year > Cal.NumberOfYears, %end of data check
                    Cal.EndFlag = 1;
                end
            elseif Cal.DayOfMonth == Cal.DaysInMonth(Cal.Month), %end of month check
                Cal.PrevMonth = Cal.Month;
                if Cal.PrevMonth == 1,
                    Cal.PrevYear = Cal.Year;
                end
                Cal.Month = Cal.Month + 1;
                Cal.PrevDayOfMonth = Cal.DayOfMonth;
                Cal.DayOfMonth = 1;
                Cal.PrevDayOfYear = Cal.DayOfYear;
                Cal.DayOfYear = Cal.DayOfYear + 1;
            else
                Cal.PrevDayOfMonth = Cal.DayOfMonth;
                Cal.DayOfMonth = Cal.DayOfMonth + 1;
                Cal.PrevDayOfYear = Cal.DayOfYear;
                Cal.DayOfYear = Cal.DayOfYear + 1;
            end
        end
        
        function resetFlags(Cal)
            Cal.FirstDayFlag = 1;
        end
    end
end