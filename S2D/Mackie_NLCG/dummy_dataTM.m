clear all;close all;

%read data

S_num=24;
%F_num=5;

inc =1/5

index =0
for iper = -1:inc:4
   index=index+1
   T(index) = 10^iper   
end
   
%freq=[0.01,0.1,1,10,100]

T_num = length(T)


rho_dum = 100
pha_dum = -45
rho_dum_error = 0.01
pha_dum_error = 0.01

%write data

str='input.tm';
fid1=fopen(str,'w+');
fprintf(fid1,'%3.0f',S_num);
fprintf(fid1,'\n')

for j=1:S_num
   fprintf(fid1,'%3.0f',T_num);
   fprintf(fid1,' %5.4f',1);
   fprintf(fid1,'\n');
   for i=1:T_num
      fprintf(fid1,'%9.3f',T(i));
      fprintf(fid1,'      (');
      fprintf(fid1,' %7.3f',rho_dum);
      fprintf(fid1,'     ,');
      fprintf(fid1,' %7.3f',pha_dum);
      fprintf(fid1,'    )');
      fprintf(fid1,'   %8.4f',rho_dum_error);
      fprintf(fid1,'       %8.4f',pha_dum_error);
      fprintf(fid1,'\n');
   end
end

fclose(fid1);
