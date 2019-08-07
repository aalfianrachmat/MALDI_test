%{
Date     : 07-08-2019
Author   : Alfian Rachmat Akbar (System Engineer)

Objective: This program is used to calculate the performance of the stage
           with repetitive 35um steps
Inputs   : File name (.csv) of the recorded target position and linear
           encoder reading

           The csv data contains information as follows:
           |target_pos|linear_encoder|

Outputs  : The output of this program:
           1. Histogram of deviation between 'linear_encoder - target_pos'
%}

%% Initialization
%--------------------------------------------------------------------------
% Clear all
clc; clear all; close all;

% Import data
[fileName, pathName, ] = uigetfile('*.csv', 'Select the file');
fileLocation = fullfile(pathName, fileName);
fileID = fopen(fileLocation, 'r');
data   = textscan(fileID, '%f %f');
fclose(fileID);

%% Data Processing
%--------------------------------------------------------------------------
% Split filename
fileName_low   = lower(fileName);
fileName_split = split(fileName_low, '_');

% Check axis
isXaxis = sum(contains(fileName_split, 'xaxis'));
isYaxis = sum(contains(fileName_split, 'yaxis'));

if isXaxis
    plt_title = 'X-axis deviation distribution with 35 $\mu$m steps';
    plt_xlabel= 'Error [$\mu$m]';
    plt_ylabel= 'Number of error';
    axis_name = 'xaxis';
elseif isYaxis
    plt_title = 'Y-axis devitaion distribution with 35 $\mu$m steps';
    plt_xlabel= 'Deviation [$\mu$m]';
    plt_ylabel= 'Number of Deviation';
    axis_name = 'yaxis';
end

% Calculate error
inc2mm     = -20000;
pos_target = data{1,1}(3:end);
pos_real   = data{1,2}(3:end)/inc2mm;
pos_real   = pos_real - pos_real(1) + pos_target(1); % Remove offset
pos_error  = pos_real - pos_target;
pos_error  = pos_error * 1e3; % From mm to um

% Calculate std and mean
error_2std = 2*std(pos_error);
error_mean = mean(pos_error);

%% Plot Histogram
%--------------------------------------------------------------------------
histogram(pos_error, 30);
title(plt_title,'Interpreter','Latex');
xlabel(plt_xlabel,'Interpreter','Latex');
ylabel(plt_ylabel,'Interpreter','Latex');
grid on;
shg;


%% Save Result
%--------------------------------------------------------------------------
% Create unique name
time_stamp = string(regexp(lower(fileName), '20[_-0-9]+[0-9]', 'match'));
proto_id   = string(regexp(lower(fileName), 'proto[_0-9]+[0-9]', 'match'));
test_id    = string(regexp(lower(fileName), 'tc[0-9]+', 'match'));
% Create Directory
mkdir(pathName, 'Result');

% Save file
space = '_';
save_name= test_id + space + proto_id + space + axis_name + space + time_stamp;
save_name= char(save_name);
save_dir = fullfile(pathName,'Result','\',save_name);

save(save_dir); % Save workspace
saveas(gcf, save_dir); % Save figure







