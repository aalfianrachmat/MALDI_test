%{
Date     : 07-08-2019
Author   : Alfian Rachmat Akbar (System Engineer)

Objective: This program is used to calculate the stage height repeatability 
           with respect to insert-out of the ASTA stage into the chamber 

Inputs   : File name (.csv) of the recorded air pressure inside the vacuum
           chamber. 

           The text data contains information as follows:
           |height|

Outputs  : The output of this program:
           1. Height repeatability
%}

%% Initialization
%--------------------------------------------------------------------------
% Clear all
clc; clear all; close all;

% Import data
[fileName, pathName, ] = uigetfile('*.csv', 'Select the file');
fileLocation = fullfile(pathName, fileName);
fileID = fopen(fileLocation, 'r');
data   = textscan(fileID, '%f');
fclose(fileID);


%% Process the data
%--------------------------------------------------------------------------
% Get the height position
pos = data{1,1};

% Normalize the height data
pos = pos - mean(pos);

% Calculate the repeatability
repeatability = 2*std(pos);

%% Plot the height repeatability
plot(pos, 'o', 'MarkerFaceColor', 'b');
axis([-inf inf -15 15]);
title('Z-repeatability')
xlabel('Measurement Sample', 'interpreter', 'Latex')
ylabel('Relative chage of the height [$\mu$m]', 'interpreter', 'Latex')
grid on

%% Save Result
%--------------------------------------------------------------------------
% Create unique name
time_stamp = string(regexp(lower(fileName), '20[_-0-9]+[0-9]', 'match'));
proto_id   = string(regexp(lower(fileName), 'proto[_0-9]+[0-9]', 'match'));
test_id    = string(regexp(lower(fileName), 'tc[0-9]+', 'match'));
% Create Directory
mkdir(pathName, 'Result');

% Save file
save_name= join(string({test_id, proto_id, time_stamp}), '_');
save_name= char(save_name);
save_dir = fullfile(pathName,'Result','\',save_name);

save(save_dir); % Save workspace
saveas(gcf, save_dir); % Save figure

