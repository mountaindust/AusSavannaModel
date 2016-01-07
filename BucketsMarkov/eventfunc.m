function [value,isterminal,direction] = eventfunc(t,y)
%stop integration when grass bucket = 0
value = y(1);
isterminal = 1;
direction = -1;
end