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
    deltta 
    u 
    k 
    l 
    E 
    e 
    w 
    r 
    lambdda_1
    lambdda_2
    z
    pe
    Pe
    ; 

varexo 
    eps_z
    eps_pe
    A
    ;

parameters 
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
rho_z=.9;
rho_pe=.789;
sig_z=.07;
sig_pe=0.055915;
B=1;

%----------------------------------------------------------------
% 3. Model (the number refers to the equation in the paper)
%----------------------------------------------------------------
model;
    %resource constraint (1)
    c+i=w*l+r*u*k(-1)+Pe*e;

    %environmental policy (2)
    e-A;

    %law of motion for investment in capital (3)
    i=k-(1-deltta)*k(-1);

    %depreciation rate of capital function (4)
    deltta=(omegga0/omegga1)*u^omegga1;

    %production function (5)
    y=(exp(z)*l)^thetta*(k(-1)*u)^(gammma)*e^kapppa;

    %energy loss: (6)
    e=(1-sigmma)*E;

    %Intratemporal efficiency condition governing labor supply (7)
    c*(1-varphhi)=varphhi*w*(1-l);

    %Marginal depreciation and energy cost equal marginal return (8):
    gammma*y/u=omegga0*u^(omegga1-1)*k(-1);

    %Euler's equation: (9)
    lambdda_1=betta*lambdda_1(+1)*(r(+1)*u(+1)+1-deltta(+1));

    %Labor marginal productivity (10)
    w=thetta*y/l;

    %Capital marginal productivity (11)
    r=gammma*y/(k(-1)*u);

    %lagrange multiplier (12)
    lambdda_1=varphhi*(((c^varphhi)*((1-l)^(1-varphhi)))^(1-alphha))/c;

    %technology shock (13)
    z=rho_z*z(-1)+eps_z;

    %oil shock (14)
    pe=rho_pe*pe(-1)+eps_pe;

    %marginal productivity of oil (15)
    kapppa*y/e=exp(pe)+lambdda_2;

    %price of oil:
    Pe=exp(pe)+lambdda_2;

    
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
    deltta=0.0125;
    u=.81;
    k=9.550602731;
    lambdda_1=0.710777024;
    A=0.026164033;
    lambdda_2=0;
end;
steady;


model_diagnostics;



perfect_foresight_setup(periods=300);
perfect_foresight_solver;
rplot e;
rplot y;
rplot k;
rplot r;
rplot u;