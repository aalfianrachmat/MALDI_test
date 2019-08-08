%{
Date     : 08-08-2019
Author   : Alfian Rachmat Akbar (System Engineer)

Objective: This program is used to examine the maxon motor EC45 winding
           temperature behavior under vacuum

Inputs   : File name (.csv) of the recorded winding temperature in vacuum

Outputs  : The output of this program:
           1. Transient of the temperature
%}

%% Initialization and Data processing
%--------------------------------------------------------------------------
% Clear all
clc; clear all; close all;

% Import data
[fileName, pathName, ] = uigetfile('*.csv', 'Select the file');
fileLocation = fullfile(pathName, fileName);
fileID   = fopen(fileLocation, 'r');
sampling = 0.1; % Sampling 100ms
data     = func_readGraphtecTemp(fileID, 0.1);
fclose(fileID);

%% Plot the temperature
%--------------------------------------------------------------------------
% Get the number of column in the table
num_column = size(data,2);

% Iterate through each table column and plot the temperature
h = []; % Create empty figure handle
hold on;
for column = 1:size(data,2)-3
   % Cretae figure object
   p = plot(data.time, data{1:end,column+3},...
       'DisplayName', data.Properties.VariableNames{column+3});
   
   % Stack figure object
   h = [h;p];
end
set(legend(h), 'Interpreter', 'none'); % Activate legend
hold off;
title('Temperature Measurement')
xlabel('Time [s]');
ylabel('Temperature [^\circC]', 'Interpreter', 'tex')
grid on

%% Save Result
%--------------------------------------------------------------------------
% Create unique name
save_name= ['result', '_', fileName(1:end-4)];
% Create Directory
mkdir(pathName, 'Result');

% Save file
save_dir = fullfile(pathName,'Result','\',save_name);

save(save_dir); % Save workspace
saveas(gcf, save_dir); % Save figure