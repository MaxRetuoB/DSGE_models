%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Third DSGE model - maxime.bouter [at] univ-pau.fr
%% this file is the first script for my first PhD chapter



%----------------------------------------------------------------
% 1. Defining variables
%----------------------------------------------------------------
var 
    c 
    i 
    y 
    k 
    l 
    E 
    e 
    w 
    r 
    lambdda_1
   %lambdda_2
    z
    pe
    ; 

varexo 
    eps_z
    eps_pe;
%varexo_det
%    A
%    ;

parameters 
    %Deltta
    omegga0 
    omegga1 
    thetta       
    gammma 
    sigmma 
    varphhi
    alphha 
    betta 
    kapppa 
    rho_z 
    rho_pe
    sig_z 
    sig_pe
    B
    iottta
    u 
    deltta 
    ;


%----------------------------------------------------------------
% 2. Calibration
%----------------------------------------------------------------
omegga0=0.033082196;
omegga1=1.808080808;
thetta=0.63;
gammma=0.33;
sigmma=0.3;
varphhi=0.26792961;
alphha=2;
betta=0.99;
kapppa=0.04;
rho_z=0.89581;
rho_pe=.789;
sig_z=0.035272;
sig_pe=0.055915;
B=1;
iottta=.0174;
deltta=0.0125;
u=0.81;


%----------------------------------------------------------------
% 3. Model (the number refers to the equation in the paper)
%----------------------------------------------------------------
model;
    %resource constraint (1)
    c+i=w*l+r*u*k(-1)+exp(pe)*e;

    %environmental policy (2)
    %e-A;

    %law of motion for investment in capital (3)
    i=k-(1-deltta)*k(-1);

    %production function (4)
    y=(exp(z)*l)^thetta*(k(-1)*u)^(gammma)*e^kapppa;

    %energy loss: (5)
    e=(1-sigmma)*E;

    %Intratemporal efficiency condition governing labor supply (6)
    c*(1-varphhi)=varphhi*w*(1-l);

    %Euler's equation: (7)
    lambdda_1=betta*lambdda_1(+1)*(r(+1)*u+1-deltta(+1));

    %Labor marginal productivity (8)
    w=thetta*y/l;

    %Capital marginal productivity (9)
    r=gammma*y/(k(-1)*u);

    %lagrange multiplier (10)
    lambdda_1=varphhi*(((c^varphhi)*((1-l)^(1-varphhi)))^(1-alphha))/c;

    %technology shock (11)
    z=rho_z*z(-1)+eps_z;

    %oil shock (12)
    pe=rho_pe*pe(-1)+eps_pe;

    %marginal productivity of oil (13)
    kapppa*y/e=exp(pe);//+lambdda_2;
 
end;
%----------------------------------------------------------------
%4. Computation of the model
%----------------------------------------------------------------


initval;
    z=0;
    l=0.22;
    E=0.037377189;
    w=1.873106878;
    r=0.027902482;
    pe=0;
    e=0.026164033;
    c=0.53471828;
    i=0.119382534;
    y=0.654100815;
    k=9.550602731;
    lambdda_1=0.710777024;
   % A=0.026164033;
end;
 
    steady;
model_diagnostics;

shocks;
var eps_z; stderr 0.035272;
var eps_pe; stderr 0.055915;
 end;
   steady;

options_.TeX=1;
stoch_simul(periods=2000,irf=150,order=2,noprint,nograph);
rplot k;
rplot y;
rplot e;
rplot i; 
options_.rplottype = 2;

write_latex_dynamic_model;
collect_latex_files;