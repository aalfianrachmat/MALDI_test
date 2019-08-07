%{
Date     : 07-08-2019
Author   : Alfian Rachmat Akbar (System Engineer)

Objective: This program is used to calculate the accuracy and repeatability
           according to NEN-ISO 230-2:2006

Inputs   : File name (.csv) of the recorded target position and linear
           encoder reading

           The csv data contains information as follows:
           |cycle|target_pos|lin_encoder|rot_encoder|

Outputs  : The output of this program:
           1. Accuracy
           2. Repeatability
%}

%% Initialization
%--------------------------------------------------------------------------
% Clear all
clc; clear all; close all;

% Import data
[fileName, pathName, ] = uigetfile('*.csv', 'Select the file');
fileLocation = fullfile(pathName, fileName);
fileID = fopen(fileLocation, 'r');
data   = textscan(fileID, '%f %f %f %f');
fclose(fileID);


%% Data Processing
%--------------------------------------------------------------------------
% Convert data into table
cycle     = data{1,1};
pos_target= data{1,2};
pos_real  = data{1,3};
pos_real  = ((pos_real - pos_real(1))/-20000) + pos_target(1); % Convert from inc2mm and remove offset
pos_rot   = data{1,4};
error_real= pos_real - pos_target;

edge = ([diff(pos_target); 0]> 0);
T    = table(cycle, edge, pos_target, pos_real, error_real);

% Remove minimum and maximum value from the table to only measure
% bidirectional position.
T.Properties.VariableNames = {'cycle', 'rising', 'pos_target', 'pos_real', 'error_real'};
T = T(T.pos_target~=min(pos_target) & T.pos_target~=max(pos_target), :);


% Create second table for calculating the accuracy and repeatbility
R = cell2table(cell(0,7), 'VariableNames', {'pos_target', 'rising', 'errors', 'mean_errors', 'std_errors', 'acc_low', 'acc_high'});
unique_target = unique(T.pos_target);
for index=1:numel(unique_target)
   errors_f = T((T.pos_target == unique_target(index)) & (T.rising == logical(1)), :).error_real; % Forward move
   errors_b = T((T.pos_target == unique_target(index)) & (T.rising == logical(0)), :).error_real; % Backward move
   
   R = [R;
        {unique_target(index), logical(1), errors_f, mean(errors_f), std(errors_f), mean(errors_f)-2*std(errors_f), mean(errors_f)+2*std(errors_f)}];
   R = [R;
        {unique_target(index), logical(0), errors_b, mean(errors_b), std(errors_b), mean(errors_b)-2*std(errors_b), mean(errors_b)+2*std(errors_b)}];
end

% Calculate bidirectional accuracy
accuracy = max(max(R.acc_low), max(R.acc_high)) - min(min(R.acc_low), min(R.acc_high))*1e3;

% Calculate bidirectional repeatabilities
repeatability = max(max([(2*R(R.rising==true,:).std_errors +...
                          2*R(R.rising==false,:).std_errors+...
                          abs(R(R.rising==true,:).mean_errors-R(R.rising==false,:).mean_errors)...
                         ),...
                         4*R(R.rising==true,:).std_errors,...
                         4*R(R.rising==false,:).std_errors...
                        ],...
                        [], 2)...
                    )*1e3;
                
% Print accuracy and repetability to console
if accuracy <= 35 
    acc_result = 'PASS';
else
    acc_result = 'FAIL';
end;

if repeatability <= 17.5 
    rep_result = 'PASS';
else
    rep_result = 'FAIL';
end;

fprintf('-----------------------------------------\n');
fprintf('|\t\tAccurcy\t\t|\tRepeatability\t|\n');
fprintf('|\t\t%.2fum\t\t|\t\t%.2fum\t\t|\n', accuracy, repeatability);
fprintf('|\t\t%s\t\t|\t\t%s\t\t|\n', acc_result,rep_result);
fprintf('-----------------------------------------\n');

%% Plot Accuracy and Repeatability
%--------------------------------------------------------------------------
% Determine the plot name based on input file
plt_title = struct('yaxis',struct('positive','Accuracy of Y-axis (X-axis at 57.25mm)',...
                                   'zero','Accuracy of Y-axis (X-axis at 0mm)',...
                                   'negative','Accuracy of Y-axis (X-axis at -57.25mm)'...
                                   ),...
                   'xaxis',struct('positive','Accuracy of X-axis (Y-axis at 38.5mm)',...
                                   'zero','Accuracy of X-axis (Y-axis at 0mm)',...
                                   'negative','Accuracy of X-axis (Y-axis at -38.5mm)'...
                                   )...       
                   );
axis_name = string(regexp(lower(fileName),'[a-z]axis', 'match'));
axis_pos  = split(lower(fileName(1:end-4)),'_');
axis_pos  = axis_pos(end);

plt_title = eval(char(join(string({'plt_title', 
                                   axis_name,
                                   axis_pos}),'.')));
               
% Plot the figure
figure(1)
hold on;
plot(R(R.rising==true,:).pos_target, R(R.rising==true,:).acc_high *1e3, '--b','DisplayName','2\sigma accuracy rising move on reinforce plate');
plot(R(R.rising==false,:).pos_target, R(R.rising==false,:).acc_high *1e3, '--r','DisplayName','2\sigma accuracy falling move on reinforce plate');
plot(R(R.rising==true,:).pos_target, R(R.rising==true,:).acc_low *1e3, '--b');
plot(R(R.rising==false,:).pos_target, R(R.rising==false,:).acc_low *1e3, '--r');
cycles = unique(T.cycle);
for i = 1:numel(cycles)
    plot(T(T.cycle==cycles(i) & T.rising==true,:).pos_target, T(T.cycle==cycles(i) & T.rising==true,:).error_real *1e3, 'ob');
    plot(T(T.cycle==cycles(i) & T.rising==false,:).pos_target, T(T.cycle==cycles(i) & T.rising==false,:).error_real *1e3, '^r');
end
title(plt_title);
xlabel('Position [mm]');
ylabel('Deviation [um]');
axis([-inf inf -40 40])
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
save_name= join(string({test_id, proto_id,axis_name,time_stamp,axis_pos}), '_');
save_name= char(save_name);
save_dir = fullfile(pathName,'Result','\',save_name);

save(save_dir); % Save workspace
saveas(gcf, save_dir); % Save figure


