%{
Date     : 09-08-2019
Author   : Alfian Rachmat Akbar (System Engineer)

Objective: Remove whitespace in txt/csv file

Inputs   : txt or csv file

Outputs  : The output of this program:
           1. new txt or csv file with whitespace removed
%}

function new_fileLocation  = func_removeWhitespaceFromText(fileLocation)
    % Open the file
    fidi=fopen(fileLocation,'r');
    
    % Create new cleaned version of the opened file
    new_fileLocation  = [fileLocation(1:end-4), '_cleaned',...
                         fileLocation(end-3:end)];
    
    fido=fopen(new_fileLocation,'w');

    % While not end of file        
    while ~feof(fidi)
      % Read line
      read_line = fgetl(fidi);  
      % String has whitespace
      if strfind(read_line,' ')
        % Remove the whitespace
        read_line=split(read_line, ' ');
        read_line=join(read_line, '');
      end
      % Write the modified line into cleaned file
      fprintf(fido,'%s\n',read_line); 
    end
    fidi=fclose(fidi);
    fido=fclose(fido);
end