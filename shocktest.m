s1=randi(300,1,1)
s2=randi([350,700],1,1)
s3=randi([801,1350],1,1)

for trial = 1:1400
 if trial == s1 || trial == s2 || trial == s3
        trigger_shock_MATLAB()
         trial
 end
   pause (0.01);
  
end
