%Bucket ODEs, simplified for Markov runs
function dN = ODEs(t,x,Vgf,gamma,g,tdrnk,epsilon,Vg_evap,Rain)
%assume all water in excess of field capacity drains immediately. (Drainage
%represents very transient dynamics in the water model.
Gam = x(1);
G = x(2);

dGam = Rain.getRain(floor(t)+1)*(1-Heavi(Gam-Vgf))-...
    epsilon*Heavi(Gam-Vg_evap)-(gamma*G+tdrnk);
dG = g;

dN = [dGam;dG];
end

function h = Heavi(y)
if y>0.5,
    h = 1;
elseif y>=0
    %continuous approximation to Heaviside function
    %interpolate between 0 and T, f\in C^1
    %f(t) = -2*t^3/T^3 + 3*t^2/T^2
    h = -2*y^3/0.125 + 3*y^2/0.25;
else
    h = 0;
end

%Note: f(t) above was found by solving the boundary value problem:
%f'(t) = at(T-t) -- all simplest polynomials w/ f'(0)=f'(T)=0
%f(0) = 0, f(T) = 1
end