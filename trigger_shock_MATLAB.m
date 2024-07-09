% [time0,sp] = trigger_shock(sp)
% --------------------------------
% usage: this script opens a serial port, sends out a pulse signal, then
% closes the serial port
%
% INPUT:
%   sp - serial port object

% OUTPUT:
%   time0 - time of pulse
%   sp - serial port object
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 16-May-2014
% based on Bob's code for triggering the scanner using a serial port & from
% ArduinoDoScan.m (vista lab code)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [time0,sp] = trigger_shock_MATLAB(sp)

try
    
    % Get a serial port
%    if notDefined('sp')
%        try
            % don't run this sentence twice otherwise you might have some problems...
            sp = serial('COM5','BaudRate',57600);
%        catch err
%            disp(err)
%            return
%        end
%    end
    
    % open the serial port
    fclose(sp); % to avoid error
    fopen(sp);
    
    
    fprintf(sp, 's'); % send pulse to trigger shock device
    time0 = GetSecs;  % get current time
    
    
    % close serial port
    % if you disconnect arduino before closing the port, matlab will be shut
    % down suddenly.
    fclose(sp);
    delete(sp);
    
catch err
    
    disp('Error occurs.')
    disp(err);
    time0 = nan;
    %
end


end % function
