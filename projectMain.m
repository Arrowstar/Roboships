clc; clear variables; format long g; close all;

%Include matlabrc, hopefully
%#function matlabrc

warning('off','MATLAB:polyshape:repairedBySimplify');
warning('off', 'MATLAB:structOnObject');

%set pathes if not deployed
if(~isdeployed) 
    addpath(genpath('classes'));
    addpath(genpath('helper_methods'));
    addpath(genpath('ui'));
end

mainGUI();