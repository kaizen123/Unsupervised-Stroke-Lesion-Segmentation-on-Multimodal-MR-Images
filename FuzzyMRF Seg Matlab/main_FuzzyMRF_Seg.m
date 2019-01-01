clear;clc;
% main_FuzzyMRF_Seg.m
% 2018/12/28 by Kechun Liu
% Function: main function of FuzzyMRF Segmentation

%% Parameters
filepath = 'C:/Users/Kechun/Desktop/daihuachen_20170518/uiwT1_brain.nii';
precision = 5;
CalType = 2;
hard_classes = 4;
fuzzy_classes = 3;

global RunTime;
RunTime = datestr(now,30);

%% Check Parameters
if(precision<1 || precision>20)
    writelog("Error:Invalid input! \nprecision must be bigger than 1 and smaller than 20.");
    error('Error:Invalid input! \nprecision must be bigger than 1 and smaller than 20.');
end

if(CalType ~= 1 && CalType ~= 2 && CalType ~= 3)
    writelog("Error:Invalid input! \nCalType for MRF must be 1, 2 or 3.");
    error('Error:Invalid input! \nCalType for MRF must be 1, 2 or 3.');
end

if(hard_classes<=1)
    writelog('Error:Invalid input!\nnumber of hard classes must be greater than 1. ');
    error('Error:Invalid input!\nnumber of hard classes must be greater than 1. ');
end

%% Log Running config
writelog(strcat('Precision: ', num2str(precision)));
if(CalType==1)
    writelog('CalType: 1    Using FAST Method.');
elseif(CalType==2)
    writelog('CalType: 2    Using Selective Updating ICM Method without Multifractal.');
else
    writelog('CalType: 3    Using Selective Updating ICM Method with Multifractal.');
end

%% Read in Nifti data
data = load_nii(filepath);
data_in = data.img; % uint32 3-D data
DATA_MAX = max(max(max(data_in)));
[X,Y,Z] = size(data_in);
% check data validity
if(DATA_MAX<=1)
    writelog('Error: Max intensity must be greater than 1.');
    error('Error: Max intensity must be greater than 1.');
end
if(X*Y*Z<=1)
    writelog('Error: Number of voxels must be greater than 1.');
    error('Error: Number of voxels must be greater than 1.');
end

%% Create the histogram of the data, and fit it with Gaussian functions
data_array = reshape(data_in, 1, []);
data_array = double(data_array(find(data_array)));
% Initialize the histogram and Gaussian parameters
[histo,mu,min_range,max_range] = histo_init(data_array, DATA_MAX, hard_classes, fuzzy_classes); % min&max range seem useless.
% By Comparison and observation in the fitting, seems that the fitting
% doesn't help since the initialization is done by kmeans. That's to say,
% the result of kmeans is good enough.

% % Proceed the fitting operation
% [mu, sigma, weight] = fit_uncon(histo, mu);

%% Calculate the Multifractal Labels
% Multifractal is used to speed up the process. not finished yet. 
% the main operation in this block about Multifractal is to calculate the
% gradient.
% In the next block, SUICM, algorithms with Multifractal need to be
% implemented also.

%% Run Selective Update ICM to determine labels
% set the effective border. 
border = cal_border(data_in);
% Mapping relationship between grey level and label(expanded)
threshold = threshold_fuzzy(mu, precision, DATA_MAX);
% Initialize labels on 3-D data
data_label = zeros(size(data_in));
for i = 2:length(threshold)
    data_label(find(data_in>=threshold(i-1) & data_in<threshold(i))) = i-1;
end
% using the entire ICM method
if(CalType == 2 || CalType == 3)
    suicm(data_in, data_label, length(threshold)-1, DATA_MAX, hard_classes, fuzzy_classes, precision);
end









