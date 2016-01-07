%Buckets + grass only equations - stochastic
function dN = BuckSODEs(t,x)

global Vg delta gamma VR g c rain Vgf Vg_evap omegaT epsilon

Gam = x(1);
R = x(2);
G = x(3);

dGam = rain(floor(t))*(1-Heavi(Gam-Vg)) - epsilon*Heavi(Gam-Vg_evap) - ...
    delta*Heavi(Gam-Vgf)*(1-Heavi(R-VR))-(gamma*G+omegaT)*Heavi(Gam);
dR = delta*Heavi(Gam-Vgf)*(1-Heavi(R-VR))-omegaT*(1-Heavi(Gam))*Heavi(R);
dG = g*Heavi(Gam)-c*G*(1-Heavi(Gam));

dN = [dGam;dR;dG];
end

function h = Heavi(y)
if y>0.5,
    h = 1;
elseif y>=0
    %continuous approximation to Heaviside function
    %interpolate between 0 and T, f\in C^1
    %interpol(t) = -2*t^3/T^3 + 3*t^2/T^2
    h = -2*y^3/0.125 + 3*y^2/0.25;
else
    h = 0;
end

%Note: the function interpol(t) above was found by solving the boundary value problem:
%f'(t) = at(T-t) -- all simplest polynomials w/ f'(0)=f'(T)=0
%f(0) = 0, f(T) = 1
end