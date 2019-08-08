%{
Date     : 08-08-2019
Author   : Alfian Rachmat Akbar (System Engineer)

Objective: This program is used to read the temperature data from Graphtec
           data logger

Inputs   : - File ID of the csv file containing temperature measurement
           - Sampling time in s

Outputs  : The output of this program:
           1. Table containg temperature measurement
%}

function T = func_readGraphtecTemp(fileID, dt)
     M = containers.Map({'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'},...
                        {'one', 'two', 'three', 'four', 'five', 'six',...
                        'seven', 'eight', 'nine', 'ten'});

    % Reset the read position
    frewind(fileID);
    % Read string data per line (excluding new line)
    read_line = fgetl(fileID);
    iter      = 1; % Initialize the iteration number
    n_channel = 0; % Initialize number of channels to zero
    measrow   = 0; % Initialize starting row of data
    while read_line ~= -1 % While the new line is not empty
        % Read line and update iteration number
        read_line = fgetl(fileID);
        iter = iter+1;
        
        % Convert the string to lower and split them
        read_line_split = split(lower(read_line), ',');
        
        % Find row index where CH is defined and calculate how many
        % channels are being used
        match = regexp(read_line_split(1), 'ch[0-9]+', 'match');
        if sum(cell2mat(match)) > 0
           n_channel = n_channel + 1; 
           eval([char(join(string({'dataFrame',...
                 'channel',M(char(string(n_channel)))}),'.')),...
                 '=', 'match', ';']);
        end
        if read_line_split(1) == string(1)
            measrow = iter;
            dataFrame.measrow     = measrow;
            dataFrame.num_channel = n_channel;
            break; % Stop while iteration
        end
    end
    % Reset the read position
    frewind(fileID);
    % Define the format specifier
    format_specifier = ['%d', '%s', '%d',...
                        repmat('%f', [1,dataFrame.num_channel]),...
                        '%*s','%*s'];
    dataFrame.data = textscan(fileID,format_specifier, 'Delimiter', ',',...
                              'Headerlines', dataFrame.measrow-1);

    %%  Convert dataFrame into Table                  
    T = table;
    T.index= dataFrame.data{1,1};
    T.date = dataFrame.data{1,2};
    T.time = T.index * dt;
    for i=4:length(dataFrame.data)
        channel_name = char(eval(['dataFrame.channel.',...
                                  char(M(num2str(i-3)))]));
        eval(['T.', 'temp_',channel_name ,'= dataFrame.data{1,i};']);
    end                      
                          
end