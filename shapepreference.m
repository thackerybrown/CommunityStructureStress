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

shapecounts = zeros(3,15);
nodecounts= zeros (3,15);
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


    for j=1:15
      if responses(1,5) == j
          nodecounts(2,j)= nodecounts(2,j)+1;
          if responses(1,9)== 1 
               nodecounts(1,j)= nodecounts(1,j)+1;
          end
      end
      if responses(1,6)== j
          shapecounts(2,j)= shapecounts(2,j)+1;
          if responses(1,9)== 1 
               shapecounts(1,j)= shapecounts(1,j)+1;
          end
      end
    end

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
    
    
    for j=1:15
      if responses(i,5) == j
          nodecounts(2,j)= nodecounts(2,j)+1;
          if responses(i,9)== 1 && prevresponse == 0  
               nodecounts(1,j)= nodecounts(1,j)+1;
          end
      end
      if responses(i,6)== j
          shapecounts(2,j)= shapecounts(2,j)+1;
          if responses(i,9)== 1 && prevresponse == 0  
               shapecounts(1,j)= shapecounts(1,j)+1;
          end
      end
    end
    
    prevnode=responses(i,5);
    prevresponse= responses(i,9);
end

for j=1:15
    nodecounts(3,j)=round(nodecounts(1,j)/nodecounts(2,j),4);
    shapecounts(3,j)=round(shapecounts(1,j)/shapecounts(2,j),4);
end

totalresponses=nodeselected+otherselected+lagselected;
