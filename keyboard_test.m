WaitSecs(1);
rt=-1;
fprintf('ready for input');
while (rt == -1)
               [keyIsDown,secs,keyCode] = KbCheck;
               if (keyIsDown)
                   response=1;
                   keyCode 
                   rt = 1;
               end
end