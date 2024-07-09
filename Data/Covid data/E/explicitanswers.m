%% input subject number
clear all;
clc;
datafile= 'nodelabels.mat';
load(datafile);
table=nodes;


prompt = {'Subject number: '};
defaults = {'', '','1'};
answer = inputdlg(prompt, 'Experimental setup information', 1, defaults);
[subjectNumber] = deal(answer{:});   

row = str2num(subjectNumber);

answers_1 = num2str(table(row,3));
answers_2 = num2str(table(row,15));
answers_3 = num2str(table(row,14));
answers_4 = num2str(table(row,2));

questionA = strcat('Question A',' a)',answers_1,' b)',answers_2,' c)',answers_3,' d)', answers_4);
fprintf(questionA);


answers_1 = num2str(table(row,5));
answers_2 = num2str(table(row,8));
answers_3 = num2str(table(row,6));
answers_4 = num2str(table(row,4));

questionB = strcat('\nQuestion B',' a)',answers_1,' b)',answers_2,' c)',answers_3,' d)', answers_4);
fprintf(questionB);

answers_1 = num2str(table(row,11));
answers_2 = num2str(table(row,13));
answers_3 = num2str(table(row,12));
answers_4 = num2str(table(row,9));

questionC = strcat('\nQuestion C',' a)',answers_1,' b)',answers_2,' c)',answers_3,' d)', answers_4);
fprintf(questionC);

answers_1 = num2str(table(row,15));
answers_2 = num2str(table(row,1));
answers_3 = num2str(table(row,4));
answers_4 = num2str(table(row,2));

questionD = strcat('\nQuestion D',' a)',answers_1,' b)',answers_2,' c)',answers_3,' d)', answers_4);
fprintf(questionD);

answers_1 = num2str(table(row,5));
answers_2 = num2str(table(row,9));
answers_3 = num2str(table(row,6));
answers_4 = num2str(table(row,7));

questionE = strcat('\nQuestion E',' a)',answers_1,' b)',answers_2,' c)',answers_3,' d)', answers_4);
fprintf(questionE);

answers_1 = num2str(table(row,11));
answers_2 = num2str(table(row,10));
answers_3 = num2str(table(row,12));
answers_4 = num2str(table(row,14));

questionF = strcat('\nQuestion F',' a)',answers_1,' b)',answers_2,' c)',answers_3,' d)', answers_4, '\n');
fprintf(questionF);
