function output = sub_cycle_sim_pulse(initConds,f0,Q,k,F0,Fe,df,tau,Fs,tp,N,td)
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
% Fe    = electrostatic force (N)
% df    = maximum frequency shift (Hz)
% tau   = relaxation time-constant (s)

% Filter/simulation parameters:
%
% Fs    = sample rate (samples/s)
% N     = # of pulses to apply
% tp    = pulse width
% td    = pulse delay from 0-phase

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

syms y(t) t

W0 = f0*2*pi;       % Ang. freq.
T = 1/f0;           % Period
m = k/W0^2;
%dW = 277.53;
dW = df*2*pi;

ts = 1/Fs;
tTrig = Q*T*3;                  % Trigger time at 3*Q periods into the sim.
tTotal = tTrig*2;               % Total sim time

% Make sure the pulse width is small enough for the total time:
if tTotal <= tTrig+tp
    output = -1;
    return
end

% Shift the trigger time by 1/4 period because of the phase between
% drive/oscillatort1{N*2}(end):ts:t1{N*2}(end)+1000*T

t0 = 0:ts:tTrig+T/4+td-ts;            % Ring-up time array
t1{1} = t0(end):ts:t0(end)+tp;  
for i = 2:N*2
    t1{i} = t1{i-1}(end)+ts:ts:t1{i-1}(end)+(1-mod(i,2))*(1/f0-tp)+mod(i,2)*tp;     % Pulse-applied time array
end

% Solve another 1000 cycles past when the pulses are stopped
t2 = t1{N*2}(end):ts:t1{N*2}(end)+1000*T;


%FdFunc = @(t) F0*sin(W0*t);                   % Drive force

opts = odeset('MaxStep',ts);

% Exponential function:
expParams = [tau];
C = @(params,t) (1-exp(-(t-t1{1}(1))/params(1)));

% Frequency change(t) after exponential pulse is applied:
dWFunc = @(t) W0 - dW * C(expParams,t);

% This is the actual system response with an exponential pulse applied at t1(1):
[V1] = odeToVectorField(diff(diff(y)) + dWFunc(t)/Q*diff(y) + dWFunc(t).^2*y == Fe*C(expParams,t)/m);
% Make it a Matlab function:
M1 = matlabFunction(V1,'vars', {'t','Y'}); 
sol1{1} = ode45(M1,[t1{1}(1),t1{1}(end)],[initConds]);     %Solve it

for i = 2:N*2
    if mod(i,2)
        C = @(params,t) (1-exp(-(t-t1{i}(1))/params(1)));
        [V1] = odeToVectorField(diff(diff(y)) + dWFunc(t)/Q*diff(y) + dWFunc(t).^2*y == Fe*C(expParams,t)/m);
        M1 = matlabFunction(V1,'vars', {'t','Y'}); 
    else
        [V1] = odeToVectorField(diff(diff(y)) + W0/Q*diff(y) + W0^2*y == 0);
        M1 = matlabFunction(V1,'vars', {'t','Y'}); 
    end
    sol1{i} = ode45(M1,[t1{i}(1),t1{i}(end)],[deval(sol1{i-1},t1{i-1}(end))]);     
end
    

[V2] = odeToVectorField(diff(diff(y)) + W0/Q*diff(y) + W0^2*y == 0);
M2 = matlabFunction(V1,'vars', {'t','Y'});                   
sol2 = ode45(M2,[t2(1),t2(end)],[deval(sol1{N*2},t1{N*2}(end))]);  


% **** NEED TO OPTIMIZE THIS ****
% Maybe not actually, it only takes about 50ms on my laptop...


y1 = deval(sol1{1},t1{1}(1:end-1),1);
t1f = t1{1}(1:end-1);
for i = 2:N*2
    tempy1 = deval(sol1{i},t1{i},1);
    y1 = horzcat(y1,tempy1(1:end-1));
    t1f = horzcat(t1f,t1{i}(1:end-1));
end
y2 = deval(sol2,t2,1);
tf = horzcat(t1f,t2);
yf = horzcat(y1,y2);

output = vertcat(tf,yf);
