%% Scheduling Program Master Program
% Attempt to run all of the parts from a single program ...

preprocess.m

load gaInputs.mat

[x,fval,exitflag,output,population,score] = gaMultiObjPareto(numMissions);

save myans.mat fval output population score x

Results(fval, x)