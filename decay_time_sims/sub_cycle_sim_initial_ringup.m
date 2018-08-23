function output = sub_cycle_sim_initial_ringup(f0,Q,k,F0,Fs,td)
%
% This script solves the equation for a damped-driven harmonic oscillator
% with the parameters given
% 
% It outputs the raw 'deflection' signal and time values without
% post-processing. A pulse is applied at a given 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cantilever parameters:
%
% f0    = resonance frequency (Hz)
% Q     = Q-factor 
% k     = spring constant (N/m)

% Force parameters:
%
% F0    = drive force (N)

% Filter/simulation parameters:
%
% Fs    = sample rate (samples/s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syms y(t) t

W0 = f0*2*pi;       % Ang. freq.
T = 1/f0;           % Period
m = k/W0^2;         % Effective mass

ts = 1/Fs;
tTrig = Q*T*3;                  % Trigger time at 3*Q periods into the sim.

% Shift the trigger time by 1/4 period because of the phase between
% drive/oscillator

t0 = 0:ts:tTrig+T/4+td;            % Ring-up time array

FdFunc = @(t) F0*sin(W0*t);                   % Drive force

opts = odeset('Refine',10,'MaxStep',(t0(2)-t0(1)));

% This function makes the 2nd order diff eq. into a system of 1st orders:
[V0] = odeToVectorField(diff(diff(y)) + W0/Q*diff(y) + W0^2*y == FdFunc(t)/m*1e9);
M0 = matlabFunction(V0,'vars', {'t','Y'});   % Make it a Matlab function
sol0 = ode23(M0,[t0(1),t0(end)],[0 1],opts);      % Solve it, y(0) = 0, y'(0) = 1

output = sol0;
