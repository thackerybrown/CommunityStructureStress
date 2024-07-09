%% boilerplate
ListenChar(2);
HideCursor;
KbName('UnifyKeyNames');
GetSecs;
seed = sum(100*clock);
rand('twister',seed);

%% screen set-up
Screen('Preference', 'SkipSyncTests', 1); 
res = Screen('Resolution',0);
mainWindow = Screen(0,'OpenWindow');
screenX = res.width;
screenY = res.height;
centerX = screenX/2;
centerY = screenY/2;
screenRect = [0,0,screenX,screenY];
backColor = 255;
Screen('GetFlipInterval', mainWindow, 100, 0.00005, 3);
FlushEvents('keyDown');

%workup test
Screen(mainWindow,'FillRect',backColor);
instructString = 'You will now complete a shock workup to calibrate the shock level.';
DrawFormattedText(mainWindow,instructString,'center','center',0,0,0,0,2)
Screen('Flip',mainWindow);
rotate=0;
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
     elseif (temp == 's')
        trigger_shock_MATLAB()
    end
end
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);

FlushEvents('keyDown');