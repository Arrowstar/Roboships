clc; clear variables; format long g; close all force;

%Include matlabrc, hopefully
%#function matlabrc

warning('off', 'MATLAB:polyshape:repairedBySimplify');
warning('off', 'MATLAB:structOnObject');

%set pathes if not deployed
if(~isdeployed) 
    restoredefaultpath();
    addpath(genpath('classes'));
    addpath(genpath('helper_methods'));
    addpath(genpath('ui'));
end

%remove any previously running timers
delete(timerfindall); 

%start main UI
mainGUI_App();