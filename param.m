%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comparing the Effects of Persistence of TFP shocks using the basic RBC
% Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
betta_vec = 0.94:0.01:0.99;
nn=length(betta_vec);
tt=2000;
 cc=zeros(tt,nn); 
 ii=zeros(tt,nn);  
 yy=zeros(tt,nn);  
 delttadeltta=zeros(tt,nn);
 uu=zeros(tt,nn); 
 kk=zeros(tt,nn); 
 ll=zeros(tt,nn); 
 EE=zeros(tt,nn); 
 ee=zeros(tt,nn);
 ww=zeros(tt,nn); 
 rr=zeros(tt,nn); 
 lambdda_1lambdda_1=zeros(tt,nn); 
 zz=zeros(tt,nn);
 pepe=zeros(tt,nn);
 
for j=1:length(betta_vec);
betta=betta_vec(j);
save parameterfile betta; 
dynare dsge_quotas1.mod noclearall
 cc(:,j)=c; 
 ii(:,j)=i;  
 yy(:,j)=y;  
 delttadeltta(:,j)=deltta;
 uu(:,j)=u; 
 kk(:,j)=k; 
 ll(:,j)=l; 
 EE(:,j)=E; 
 ee(:,j)=e;
 ww(:,j)=w; 
 rr(:,j)=r; 
 lambdda_1lambdda_1(:,j)=lambdda_1; 
 zz(:,j)=z;
 pepe(:,j)=pe;
end
return


%%blablabla
for i=1:length(psi_params)
psi = psi_params(i);
stoch_simul(noprint, nograph);
pi_eps_a_mat(:,i) = pi_eps_a;
end

clear all;
close all;
psiv=[0.001 0.01 0.2 0.03 0.04 0.05];


close all;
time=1:40;


subplot(2,3,1)
plot(time',C(1:40,2),'--',time',C(1:40,3),'-.', time, C(1:40,4),'LineWidth',2)
title('C')


subplot(2,3,2)
plot(time',L(1:40,2),'--',time',L(1:40,3),'-.', time, L(1:40,4),'LineWidth',2)
title('L')

subplot(2,3,3);
plot(time',K(1:40,2),'--',time',K(1:40,3),'-.', time, K(1:40,4),'LineWidth',2)
title('K')

subplot(2,3,4)
plot(time',w(1:40,2),'--',time',w(1:40,3),'-.', time, w(1:40,4),'LineWidth',2)
title('w')

