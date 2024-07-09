 % Community structure experiment
 
%% input dialog box 
clear all;
clc;
prompt = {'Subject number: '};
defaults = {'', '','1'};
answer = inputdlg(prompt, 'Experimental setup information', 1, defaults);
[subjectNumber] = deal(answer{:});   

%% boilerplate
ListenChar(2);
HideCursor;
KbName('UnifyKeyNames');
GetSecs;
seed = sum(100* clock);
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

%% stimulus information
shapeSize = 100;
borderThickness = .06;
imageRect = [0,0,shapeSize,shapeSize];
imageCenterRect = [centerX-shapeSize/2,centerY-shapeSize/2,centerX+shapeSize/2,centerY+shapeSize/2];
shapeDuration = 1.5;
numTargets = 60;
motionRange = 100;
beepHigh = MakeBeep(587.33,.1);
beepLow = MakeBeep(440,.1);
Snd('Open');
intrinsicRotation=[172,204,64,52,4,6,48,74,95,302,174,136,225,105,297];%Randi(360,[1 15]);
shapeAssignment = Shuffle(1:15);

%% output file
dataFile = fopen(['data_' subjectNumber '.txt'], 'a');
fprintf(dataFile,'*********************************************\n');
fprintf(dataFile,['* Date/Time: ' datestr(now, 0) '\n']);
fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
fprintf(dataFile,['* Subject Number: ' num2str(subjectNumber) '\n']);
fprintf(dataFile,'%d\t',shapeAssignment);
fprintf(dataFile,'\n*********************************************\n\n');
subjectNumber = str2num(subjectNumber);

%% generate sequences

% number of seconds of experiment = shapeDuration*(length+test_length*subtest_length*2)+exposureTime+instruction reading

%generate training
length=1400; %length of training %%should be 1400
 % community 1 = 1,2,3,14,15;
 % community 2 = 4,5,6,7,8;
 % community 3 = 9,10,11,12,13; 
graph=[15,14,2,3;1,15,14,3;2,1,15,4;3,5,6,7;4,8,7,6;5,4,7,8;4,5,6,8;5,6,7,9;8,10,11,12;9,11,12,13;10,9,13,12;13,11,9,10;12,14,11,10;13,15,1,2;1,2,3,14];
curr=Randi(15);
record=zeros(0,length);
for i=1:length
    next=Randi(4);
    curr=graph(curr,next);
    record(i)=curr;
end
shapeSequence = record;

% generate testing
test_length=20; % total num of elements = test_length*subtest_length*2 %should be 20 
subtest_length=15; %should stay a  t 15
curr=Randi(15);
record=zeros(0,length); 
index=1;

%clockwise transitions
clockwise = 1:15;
 
%counterclockwise transitions
counterclockwise = 15:-1:1;

for j=1:test_length
     % generating a random walk for 15 items
    for i=1:subtest_length 
        next=Randi(4);
        curr=graph(curr,next);
        record(index)=curr;
        index=index+1;
    end
    
     % choose a hamiltonian path for next 15 items
    direction=Randi(2); %choose clockwise vs. counterclockwise
    if direction == 1
        hamiltonian=clockwise;
    else
        hamiltonian=counterclockwise;
    end
 
    % fitting the two walks together
    currindex = find(hamiltonian == curr);
    for i=1:subtest_length
        currindex = currindex+1;
        if currindex == 16; currindex = 1; end
        record(index) = hamiltonian(currindex);
        index = index+1;
    end
    curr = hamiltonian(currindex);
end
testSequence = record;

%% load images
cd abstractstims;
%cd png;
imageList = dir;
imagePath = what;
shuffleimages=[9,2,12,10,1,7,13,4,6,3,8,14,15,11,5];
for j=3:size(imageList,1)
    k=j-2;
    i = shuffleimages(k);
    stims{i} = imread([imagePath.path '/' imageList(j).name],'tiff');
    stims{i}=255-stims{i};
    stims{i}=imresize(stims{i},[100,100]);
    stims{i}=mean(stims{i},3);
    textures(i) = Screen('MakeTexture',mainWindow,stims{i});
end
cd ..;

%% play exposure
% show instructions
Screen(mainWindow,'FillRect',backColor);
instructString = 'You will be asked to detect whether the following discs have rotated.\nTry to familiarize yourself with the images.\nSpend at least a minute looking at them.\nPress the spacebar to continue...';
DrawFormattedText(mainWindow,instructString,'center',150,0,0,0,0,2)
offsetleft=430;
offsetdown=-100;
distancebetween=140;
verticaldistance=140;
for i=1:5
   Screen('DrawTexture',mainWindow,textures(i),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+offsetdown],intrinsicRotation(i));
   Screen('DrawTexture',mainWindow,textures(i+5),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+verticaldistance+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+verticaldistance+offsetdown],intrinsicRotation(i+5));
   Screen('DrawTexture',mainWindow,textures(i+10),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+verticaldistance*2+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+verticaldistance*2+offsetdown],intrinsicRotation(i+10));
end
startExposure=Screen('Flip',mainWindow);
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end
exposureTime=GetSecs-startExposure;

fprintf(dataFile,'Shape exposure time (seconds)\n');
fprintf(dataFile,'%.4f\n',exposureTime);
%% play training
% show instructions

LEFT=70; %'f'
RIGHT=74; %'j'
rotate_key='';
norotate_key='';
rotate_keynum=0;
norotate_keynum=0;
if Randi(2)==1
    norotate_key='F';
    rotate_key='J';
    norotate_keynum=LEFT;
    rotate_keynum=RIGHT;
else
    norotate_key='J';
    rotate_key='F';
    norotate_keynum=RIGHT;
    rotate_keynum=LEFT;
end

Screen(mainWindow,'FillRect',backColor);
instructString = ['Watch the stream of discs carefully.\nLook for changes in orientation of the discs.\nPress the ', norotate_key ,' key if the disc looks correct and the ', rotate_key ' key if it does not.\nTry to respond as quickly and accurately as possible to each disc.\nYou will hear a high beep if your response is incorrect and a low beep if you did not respond in time.\nThe images will continue to appear regardless of whether you have responded.\nPress the spacebar to continue...'];
DrawFormattedText(mainWindow,instructString,'center','center',0,0,0,0,2);
Screen('Flip',mainWindow);
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end
Screen('Flip',mainWindow);

% initialize trial sequence
fprintf(dataFile,'subject\ttrial\tphase\tonset\tnode\tshape\trotate\tacc\tresp\ttotal\trt\n');
FlushEvents('keyDown');

Screen(mainWindow,'FillRect',backColor);
runStart = Screen('Flip',mainWindow);
phase=1;
% show shapes
accuracycount=0;
totalaccuracy=0;
for trial=1:length
    %FlushEvents('keyDown');
    response = 0;
    rt = -1;
    accuracy=-1; 
    tempShape = shapeAssignment(shapeSequence(trial));

    rotation_choices=[0.0,0.0,0.0,0.0,90.0];
    rotate=rotation_choices(Randi(size(rotation_choices,2)));
    if rotate==90.0
        correctButton=rotate_keynum; 
    else
        correctButton=norotate_keynum;
    end
    
    % display shape
    trialStart = Screen('Flip',mainWindow,runStart+trial);
    shapeOnset = trialStart;
    %shapeOffset = trialStart+shapeDuration;
    currentTime = trialStart; 
    while(currentTime < trialStart + shapeDuration)
        Screen('DrawTexture',mainWindow,textures(tempShape),imageRect,imageCenterRect,rotate+intrinsicRotation(tempShape));
        currentTime = Screen('Flip',mainWindow);
        
        while (GetSecs-trialStart<shapeDuration)
           if (rt == -1) % not yet responded
               [keyIsDown,secs,keyCode] = KbCheck;
               if (keyIsDown)
                   response=1;
                   if (keyCode(LEFT) || keyCode(RIGHT)) 
                       rt = secs-trialStart;
                       if (keyCode(correctButton)) 
                           accuracy = 1;
                           accuracycount = accuracycount + 1;
                       else
                           accuracy = 0;
                           Snd('Play',beepHigh);
                       end
                   end
               end
           end
        end
    end
    if (response==0 || rt==-1) %also if you press wrong button (because rt will change from -1 if you press correct button)
        Snd('Play',beepLow);
    end
    totalaccuracy = accuracycount./trial;
    fprintf(dataFile,'%d\t%d\t%d\t%.4f\t%d\t%d\t%d\t%d\t%d\t%.4f\t%.4f\n',subjectNumber,trial,phase,shapeOnset-runStart,shapeSequence(trial),tempShape,rotate,accuracy,response,totalaccuracy,rt);
    
    if trial==round(3.*length./7)
        Screen(mainWindow,'FillRect',backColor);
        instructString = ['Time for another saliva sample.\nPress the spacebar when instructed by the experimenter to continue...'];
        DrawFormattedText(mainWindow,instructString,'center','center',0,0,0,0,2)
        Screen('Flip',mainWindow); 
        while(1) % wait for space bar
            FlushEvents('keyDown');
            temp = GetChar;
            if (temp == ' ')
                break;
            end
        end
    end
        
    KbReleaseWait;
    FlushEvents('keyDown');
    Screen('Flip',mainWindow);
    response=0;
end

%%workup break
Screen(mainWindow,'FillRect',backColor);
instructString = 'You will now complete another activity before the next phase of the experiment.\nAfter the break, press the spacebar when directed to by the experimenter.';
DrawFormattedText(mainWindow,instructString,'center','center',0,0,0,0,2)
Screen('Flip',mainWindow);
rotate=0;
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);

%% play test
% show instructions
phase=2;
Screen(mainWindow,'FillRect',backColor);
instructString = 'You will now be shown sequences of the discs in the correct orientation.\nSimply press the spacebar at times in the sequence that you feel are natural breaking points.\nWe know these are vague instructions - just try to use your intuition!\nNote that breaking point does not mean a pause or white screen.\nPress the spacebar now to start...';
DrawFormattedText(mainWindow,instructString,'center','center',0,0,0,0,2)
Screen('Flip',mainWindow);
rotate=0;
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);

% initialize trial sequence
FlushEvents('keyDown');
startTime = 0;
targetCounter = 0;
targetRT = zeros(1,numTargets);
targetTrial = zeros(1,numTargets);
targetShape = zeros(1,numTargets);
falseAlarms = 0;
nextRep = 0;
startDir = randsample([-1 1],1);

Screen(mainWindow,'FillRect',backColor);
runStart = Screen('Flip',mainWindow);
% show shapes
nodeparsescount=0;
nodeparsespossible=0;
otherparsescount=0;
otherparsespossible=0;
previousnode=0;
for trial=1:numel(testSequence)
    response = 0;
    rt = -1;
    accuracy=-1; 
    tempShape = shapeAssignment(testSequence(trial));
  
    % display shape
    trialStart = Screen('Flip',mainWindow,runStart+trial);
    shapeOnset = trialStart;
    shapeOffset = trialStart+shapeDuration;
    currentTime = trialStart;
    while(currentTime < trialStart + shapeDuration)
        Screen('DrawTexture',mainWindow,textures(tempShape),imageRect,imageCenterRect,intrinsicRotation(tempShape));
        currentTime = Screen('Flip',mainWindow);
        
        while (GetSecs-trialStart<shapeDuration)
           if (rt == -1) % not yet responded
               [keyIsDown,secs,keyCode] = KbCheck;
               if (keyIsDown)
                   response=1;
                   if keyCode(32) 
                       rt = secs-trialStart;
                   end
                   if (testSequence(trial)== 3 && previousnode == 4) || (testSequence(trial)== 4 && previousnode == 3) ||(testSequence(trial)== 8 && previousnode == 9) ||(testSequence(trial)== 9 && previousnode == 8) ||(testSequence(trial)== 13 && previousnode == 14) ||(testSequence(trial)== 14 && previousnode == 13)                        
                       nodeparsescount=nodeparsescount+1;
                   else 
                       otherparsescount=otherparsescount+1;
                   end   
               end
           end
        end
    end
 % community 1 = 1,2,3,14,15;
 % community 2 = 4,5,6,7,8;
 % community 3 = 9,10,11,12,13; 
    totalparses= nodeparsescount + otherparsescount;
    parsingratio=nodeparsescount/totalparses;
    if (testSequence(trial)== 3 && previousnode == 4) || (testSequence(trial)== 4 && previousnode == 3) ||(testSequence(trial)== 8 && previousnode == 9) ||(testSequence(trial)== 9 && previousnode == 8) ||(testSequence(trial)== 13 && previousnode == 14) ||(testSequence(trial)== 14 && previousnode == 13)                        
          nodeparsespossible=nodeparsespossible+1;
   else 
       otherparsespossible=otherparsespossible+1;
    end    
  nodeparsepercent=nodeparsescount/nodeparsespossible;
   otherparsepercent=otherparsescount/otherparsespossible;
   totalparsespossible=nodeparsespossible+otherparsespossible;
   chancelevel= nodeparsespossible/totalparsespossible;
    previousnode=testSequence(trial);
   
    % print data
    fprintf(dataFile,'%d\t%d\t%d\t%.4f\t%d\t%d\t%d\t%d\t%d\t%.4f\t%.4f\n',subjectNumber,trial,phase,shapeOnset-runStart,testSequence(trial),tempShape,rotate,accuracy,response,parsingratio,rt);
end

%Save parsing data
fprintf(dataFile,'Actual parsing ratio\n');
fprintf(dataFile,'%.4f\n',parsingratio);
fprintf(dataFile,'Possible node parses\n');
fprintf(dataFile,'%.4f\n',nodeparsespossible);
fprintf(dataFile,' Node parses selected\n');
fprintf(dataFile,'%.4f\n',nodeparsepercent);
fprintf(dataFile,'Possible other parses\n');
fprintf(dataFile,'%.4f\n',otherparsespossible);
fprintf(dataFile,'Other parses selected\n');
fprintf(dataFile,'%.4f\n',otherparsepercent);
fprintf(dataFile,'Chance parsing ratio\n');
fprintf(dataFile,'%.4f\n',chancelevel);


%% prompt for experimenter
instructString = 'Time for another saliva sample. \nPress the spacebar to move on to the next phase when instructed by the experimenter.';
DrawFormattedText(mainWindow,instructString,'center','center',0,0,0,0,2)
Screen('Flip',mainWindow);
while(1) 
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end

Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow); 

%% play awareness testing
% show instructions
phase=3;
Screen(mainWindow,'FillRect',backColor);
instructString = 'You will now be asked to group the discs, based on the strategy you used in the previous phase to determine breaking points.\nPlease write down your selections on the sheet provided.\nPress the spacebar now to see the discs.';
DrawFormattedText(mainWindow,instructString,'center','center',0,0,0,0,2)
Screen('Flip',mainWindow);
rotate=0;
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% display all discs
instructString = 'Question 2\nPress the spacebar to continue when you are done recording your groupings.';
DrawFormattedText(mainWindow,instructString,'center',150,0,0,0,0,2)

offsetleft=430;
offsetdown=-150;
distancebetween=140;
verticaldistance=180;
for i=1:5
   number=num2str(i);
   DrawFormattedText(mainWindow, number,(centerX-offsetleft+i*distancebetween),(centerY-shapeSize/2+offsetdown-30),0,0,0,0,2);
   Screen('DrawTexture',mainWindow,textures(shapeAssignment(i)),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+offsetdown],intrinsicRotation(shapeAssignment(i)));
   number=num2str(i+5);
   DrawFormattedText(mainWindow, number,(centerX-offsetleft+i*distancebetween),(centerY-shapeSize/2+verticaldistance+offsetdown-30),0,0,0,0,2);
   Screen('DrawTexture',mainWindow,textures(shapeAssignment(i+5)),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+verticaldistance+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+verticaldistance+offsetdown],intrinsicRotation(shapeAssignment(i+5)));
   number=num2str(i+10);
   DrawFormattedText(mainWindow, number,(centerX-offsetleft+i*distancebetween),(centerY-shapeSize/2+2*verticaldistance+offsetdown-30),0,0,0,0,2);
   Screen('DrawTexture',mainWindow,textures(shapeAssignment(i+10)),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+verticaldistance*2+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+verticaldistance*2+offsetdown],intrinsicRotation(shapeAssignment(i+10)));
end
startExposure=Screen('Flip',mainWindow);
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end

% disc awareness quiz
%instructions
Screen(mainWindow,'FillRect',backColor);
instructString = 'Question 3\nYou will now be shown a specific disc and asked to indicate which four discs you are most likely to see following that disc.\nPlease circle your selections on the sheet provided.\nPress the spacebar when you are ready to proceed.';
DrawFormattedText(mainWindow,instructString,'center','center',0,0,0,0,2)
Screen('Flip',mainWindow);
rotate=0;
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');
%question generator
questionlist=[1,7,10,3,8,13];
alphalist = ['A','B','C','D','E','F'];
for question=1:6
    if question ==6
       instructString = '\nPress the spacebar when you are ready to complete the study. Thank you for your time and participation.';
    else
        instructString = '\nPress the spacebar to move on to the next question once you have circled the four discs most likely to follow this one.';
    end
    instructString2 = strcat('Question 3',alphalist(question));
    instructString = strcat(instructString2,instructString);
    DrawFormattedText(mainWindow,instructString,'center',150,0,0,0,0,2)
    offsetleft=430;
    offsetdown=50;
    distancebetween=140;
    verticaldistance=180;
for i=1:5
   number=num2str(i);
   DrawFormattedText(mainWindow, number,(centerX-offsetleft+i*distancebetween),(centerY-shapeSize/2+offsetdown-30),0,0,0,0,2);
   Screen('DrawTexture',mainWindow,textures(shapeAssignment(i)),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+offsetdown],intrinsicRotation(shapeAssignment(i)));
   number=num2str(i+5);
   DrawFormattedText(mainWindow, number,(centerX-offsetleft+i*distancebetween),(centerY-shapeSize/2+verticaldistance+offsetdown-30),0,0,0,0,2);
   Screen('DrawTexture',mainWindow,textures(shapeAssignment(i+5)),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+verticaldistance+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+verticaldistance+offsetdown],intrinsicRotation(shapeAssignment(i+5)));
   number=num2str(i+10);
   DrawFormattedText(mainWindow, number,(centerX-offsetleft+i*distancebetween),(centerY-shapeSize/2+2*verticaldistance+offsetdown-30),0,0,0,0,2);
   Screen('DrawTexture',mainWindow,textures(shapeAssignment(i+10)),imageRect,[centerX-offsetleft-shapeSize/2+i*distancebetween,centerY-shapeSize/2+verticaldistance*2+offsetdown,centerX-offsetleft+shapeSize/2+i*distancebetween,centerY+shapeSize/2+verticaldistance*2+offsetdown],intrinsicRotation(shapeAssignment(i+10)));
end
 Screen('DrawTexture',mainWindow,textures(shapeAssignment(questionlist(question))),imageRect,[centerX-shapeSize/2,centerY-shapeSize/2-200,centerX+shapeSize/2,centerY+shapeSize/2-200],intrinsicRotation(shapeAssignment(questionlist(question)))) ;
 startExposure=Screen('Flip',mainWindow);
while(1) % wait for space bar
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end
end


%% clean up 
ListenChar(1);
sca;
fclose('all');

