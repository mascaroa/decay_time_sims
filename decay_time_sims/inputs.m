%addpath(genpath('/ltmp/mascaroa/decay_time_sims'))
addpath('~/Dropbox/git/decay_time_sims/decay_time_sims')

% I should add a params.dat file for these....
% TODO I guess

tp = [100e-9,500e-9,1000e-9,1500e-9,3000e-9];
td = [0:6:36]*1e-7;
tau = 300e-9;
fprintf('\n\nStarting script....\n\n')
run_sim_pulse(tp,td,tau)
exit

