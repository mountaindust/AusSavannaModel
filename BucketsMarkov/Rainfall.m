%class file to create rainfall for x number of years in various
%distributions

classdef Rainfall < handle
    properties
        Distribution %method to generate rainfall
        Day = -1; %current day number, interger count
        RainToday = 0; %current amount of rain
        %The following commented for memory purposes
        %RainHistory = {}; %record of rainfall generated, cell structure (for speed)
    end
    
    properties (Access = private)
        Rainstats
    end
    
    methods
        %constructor
        function Rain = Rainfall(file,type)
            if nargin < 2,
                type = 'BG';
            end
            Rain.Rainstats = csvread(file);
            Rain.Distribution = type;
        end
        
        %get rain on day t
        function rainamount = getRain(Rain,t)
            if t == Rain.Day
                %day hasn't changed
                rainamount = Rain.RainToday;
            else
                %get rain from correct distribution. use on first day.
                if strcmpi(Rain.Distribution,'BG') || Rain.Day == -1,
                    rainamount = Rain.BG(t);
                elseif strcmpi(Rain.Distribution,'M1G'),
                    rainamount = Rain.M1G(t);
                else
                    error('No such distribution')
                end
                %update current day's rainfall
                Rain.RainToday = rainamount;
                %Rain.RainHistory = {Rain.RainHistory{:},Rain.RainToday};
                %update current day
                Rain.Day = t;
            end
        end
    end
    
    methods (Access = private)
        function rainout = BG(Rain,t) %Bernoulli-Gamma
            %Row 1 of rainstats is probability of rain
            %Row 2 and 3 are gamma distribution parameters
            dd = mod(t,365)+1;
            if rand(1) < Rain.Rainstats(dd,1),
                rainout = gamrnd(Rain.Rainstats(dd,2),Rain.Rainstats(dd,3));
            else
                rainout = 0;
            end
        end
        
        function rainout = M1G(Rain,t) %Markov order 1, Gamma
            %Row 1 of rainstats is probability of rain, given current rain
            %Row 2 of rainstats is probability of rain otherwise
            %Row 3 and 4 are gamma distribution parameters
            dd = mod(t,365)+1;
            if Rain.RainToday > 0,
                if rand(1) < Rain.Rainstats(dd,1),
                    rainout = gamrnd(Rain.Rainstats(dd,3),Rain.Rainstats(dd,4));
                else
                    rainout = 0;
                end
            else
                if rand(1) < Rain.Rainstats(dd,2),
                    rainout = gamrnd(Rain.Rainstats(dd,3),Rain.Rainstats(dd,4));
                else
                    rainout = 0;
                end
            end
        end
    end
end