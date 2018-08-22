function out = run_sim_pulse(tp,td,tau)
    f0 = 277261;
    T = 1/f0;
    W0 = 2*pi*f0;
    Q = 500;
    k = 22;
    F0 = 9.85e-10;
    Fes = 3.09e-9;
    df = 277;
    Fs = 1e8;
    ts = 1/Fs;
    tp = tp;
    td = td;

    tau = tau;
    beta = 1;
    fprintf('\n\nStarting first simulation...\n\n')
    
    tic
    
    % First we need to solve the initial ring-up part, then pass this the
    % final values as the initial conditions to solve the remaining
    % time-series.
    t0end = 3*Q*T+T/4-ts;                  % end of the initial ring-up time array (for reference)
    
    % Solve it for the longest delay time (so that shorter ones can be
    % accessed without re-solving it
    [~,b] = max(td);
    sol0 = sub_cycle_sim_initial_ringup(f0,Q,k,F0,Fs,td(b));
    
    fprintf('\n\n Evaluating ring-up -> steady state solution...')
    t0Full = 0:ts:t0end+td(b);
    y0Full = deval(sol0,t0Full); 
    fprintf('  done.\n\n')
    
    % Get the end-points to use as initial conditions for the pulse-applied
    % time regions
    fprintf('Getting initial conditions for each delay time.....')
    for j = 1:length(td)
        initConds(j,:) = deval(sol0,t0end+td(j));
    end
    fprintf(' done.\n\n')
    
    
    % Iterate through each pulse length and solve each set of delay times
    % using the initial conditions from the original steady-state solution
    parpool(6)
    for i = 1:length(tp)
        parfor j = 1:length(td)
            out1 = sub_cycle_sim_pulse(initConds(j,:),f0,Q,k,F0,Fes,df,tau,Fs,tp(i),100,td(j));
            
            % If no directory for this pulse time and tau, create one then
            % save the file
            if(~exist(strcat('Q500tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/'),'dir'))
                fprintf(strcat('Creating folder:\t','tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/'))
                mkdir(strcat('Q500tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/'))
            end 
                fprintf(strcat('Writing file:\t','tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/','td_',num2str(td(j)),'.csv'))
                csvwrite(strcat('Q500tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/','td_',num2str(td(j)),'.csv'),out1)
        end 
        fprintf('\n\nDone pulse time %d ...\n\n',i)
    end
    csvwrite(strcat('Q500tau_',num2str(tau),'/','ringUp.csv'),vertcat(t0Full,y0Full));
    out = toc;
end
