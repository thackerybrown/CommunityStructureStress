 %% input subject number
clear all;
clc;
prompt = {'Subject number: '};
defaults = {'', '','1'};
answer = inputdlg(prompt, 'Experimental setup information', 1, defaults);
[subjectNumber] = deal(answer{:});   

datafile= strcat('parses_',num2str(subjectNumber),'.mat');
load(datafile);
responses=parses;

prevnode = responses(1,5);
if responses (1,9)==1
    otherselected = 1;
    prevresponse= 1;
else
    otherselected = 0;
    prevresponse= 0;
end
nodeselected = 0;
lagselected=0;
otherpossible=1;
nodepossible=0;
lagpossible=0;
nextpresslag=0;

for i = 2:600
    if (responses(i,5)== 3 && prevnode == 4) || (responses(i,5)== 4 && prevnode == 3) ||(responses(i,5)== 8 && prevnode == 9) ||(responses(i,5)== 9 && prevnode == 8) ||(responses(i,5)== 13 && prevnode == 14) ||(responses(i,5)== 14 && prevnode == 13)                        
        nodepossible=nodepossible+1;
        nextpresslag=1;
        if responses(i,9)== 1 && prevresponse == 0
            nodeselected=nodeselected+1;
        end
    elseif  nextpresslag==1
        lagpossible=lagpossible+1;
        if responses(i,9)== 1 && prevresponse == 0
            lagselected=lagselected+1;
        end
        nextpresslag=0;
    elseif nextpresslag==0
        otherpossible=otherpossible+1;
        if responses(i,9)== 1 && prevresponse == 0
            otherselected=otherselected+1;
        end
         nextpresslag=0;
    end
    prevnode=responses(i,5);
    prevresponse= responses(i,9);
end

totalresponses=nodeselected+otherselected+lagselected;
