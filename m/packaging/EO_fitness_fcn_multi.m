function [cost,sched,risk,perf] = EO_fitness_fcn_multi(x)
%% EO_fitness_fcn.m
% This function takes as an input a vector [1 x N_INSTR] called x which
% contains the assignment of instruments to satellites following the format
% below:
% x = [Sat_of_instr1 Sat_of_instr2 ... Sat_of_instrN_INSTR]
% where Sat_of_instri are all integers between 1 and N_INSTR.
%
% The outputs are the 4 different FOMs: cost, risk, schedule and performance.
%
% This function calls the functions in the Matlab model EO_Evaluate, etc.
% In order to do that it creates a structure that can be used by the model.

% We round the vector so that the numbers are all integers
x = round(x);
% x = xi;

% Debugging info
size_pop = size(x,1);
ninstr = size(x,2);


cost = zeros(size_pop,1);
sched = zeros(size_pop,1);
risk = zeros(size_pop,1);
perf = zeros(size_pop,1);

for i = 1:size_pop
    xi = x(i,:);
%     disp(['Arch = ',num2str(xi),'...']);
    fprintf('Arch = %s...',num2str(xi));
    if xi>0

        % Initialize structure with instrument parameters
        EOM = EOM_init('Envisat');

        % Copy design variables (assignment of instruments to satellites) given as
        % an input (x) onto the structure (EOM).

        nsat = max(xi);

        I2S = false(ninstr,nsat);
        for j = 1:ninstr
            I2S(j,xi(j)) = true;
        end

        EOM.Instruments2Satellites = I2S;
        EOM.NSats = nsat;
        EOM.Satellites2Launchers = logical(eye(nsat));
        EOM.NLaunchers =nsat; 

        % Call evaluation functions
        EOM = CheckFeasibility(EOM);
        EOM = EOM_Evaluate(EOM);
        EOM = EOM_Rank(EOM);

        % 4 figures of merit
        if EOM.Feasibility
            cost(i) = EOM.LifecycleCost; % Min cost
            sched(i) = EOM.MeanDevTime;% Min Development time
            risk(i) = -EOM.NIMS;% Max NIMS = min -NIMS
            perf(i) = -EOM.Performance;% Max performance = min - performance
            fprintf('...[cost = %f, devtime = %f, -risk = %f, -perf = %f]\n',cost(i),sched(i),risk(i),perf(i));
%             disp(['... [cost, sched, risk, perf] = ',num2str(cost(i)),num2str(sched(i)),num2str(risk(i)),num2str(perf(i)),'.\n']);
        else
            cost(i) = 10e9; % Unfeasible architecture.
            sched(i) = 1000; % Unfeasible architecture.
            risk(i) = 0; % Unfeasible architecture.
            perf(i) = 0; % Unfeasible architecture.
            disp('... Unfeasible.\n');
        end
    else
        cost(i) = 10e9; % Unfeasible architecture.
        sched(i) = 1000; % Unfeasible architecture.
        risk(i) = 0; % Unfeasible architecture.
        perf(i) = 0; % Unfeasible architecture.
        disp('... Unfeasible.\n');
    end
end
return
