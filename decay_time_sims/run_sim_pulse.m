function out = run_sim_pulse(tp,td,tau)
    f0 = 277261;
    T = 1/f0;
    W0 = 2*pi*f0;
    Q = 10000;
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
    fprintf('\n\nStarting initial ringup simulation...\n\n')
    
    tic
    
    % First we need to solve the initial ring-up part, then pass this the
    % final values as the initial conditions to solve the remaining
    % time-series.
    t0end = 3*Q*T+T/4-ts;                  % end of the initial ring-up time array (for reference)
    
    % Solve it for the longest delay time (so that shorter ones can be
    % accessed without re-solving it
    [~,b] = max(td);
    sol0 = sub_cycle_sim_initial_ringup(f0,Q,k,F0,Fs,td(b));
    
    %fprintf('\n\nEvaluating steady state solution for 50 cycles...')
    %t0tail = t0end+td(b)-50*T:ts:t0end+td(b);
    %y0tail = deval(sol0,t0tail,1); 
    %fprintf('\t  done.\n\n')
    
    %if(~exist(strcat('../outputs/Q10000tau_',num2str(tau))))
    %	    fprintf(strcat('\n\nCreating directory ../outputs/Q5000tau_',num2str(tau),'...')) 
    %	    mkdir(strcat('../outputs/Q10000tau_',num2str(tau)))
    %	    fprintf('  done.\n\n')
    %end
    
    %sstail = vertcat(t0tail,y0tail);
0
    %fprintf('\n\nSaving initial ring-up data...')
    %dlmwrite(strcat('../outputs/Q10000tau_',num2str(tau),'/','ringUpTail.csv'),vertcat(t0tail,y0tail),'delimiter',',','precision',9);
    %fprintf('\t  done.\n\n')

    % Get the end-points to use as initial conditions for the pulse-applied
    % time regions
    fprintf('\n\nGetting initial conditions for each delay time.....')
    for j = 1:length(td)
        initConds(j,:) = deval(sol0,t0end+td(j));
    end
    fprintf('\t done.\n\n')
    
    
    % Iterate through each pulse length and solve each set of delay times
    % using the initial conditions from the original steady-state solution
    parpool(6)
    for i = 1:length(tp)
        parfor j = 1:length(td)
            out1 = sub_cycle_sim_pulse(initConds(j,:),f0,Q,k,F0,Fes,df,tau,Fs,tp(i),100,td(j));
	    out1(1,:) = out1(1,:)-t0end;	% Zero the time when the drive is turned off            
            % If no directory for this pulse time and tau, create one then
            % save the file
            if(~exist(strcat('../outputs/Q10000tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/'),'dir'))
                fprintf(strcat('\n\nCreating folder:\t','../outputs/Q10000tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/ ...'))
                mkdir(strcat('../outputs/Q10000tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/'))
            	fprintf('\t  done.')
	    end 
                fprintf(strcat('\n\nWriting file:\t','../outputs/Q10000tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/','td_',num2str(td(j)),'.csv ...'))
		dlmwrite(strcat('../outputs/Q10000tau_',num2str(tau),'/','tp_',num2str(tp(i)),'/','td_',num2str(td(j)),'.csv')...
		,horzcat(vertcat((t0end+td(j)-T*50:ts:t0end+td(j)-ts)-t0end,deval(sol0,t0end+td(j)-T*50:ts:t0end+td(j)-ts,1)),out1)...
		,'delimiter',',','precision',9)
		fprintf('\t  done.')
        end 
        fprintf('\n\nDone pulse time %d ...\n*****************\n\n',i)
    end
    out = toc;
end
