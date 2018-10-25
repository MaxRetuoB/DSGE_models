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
        
end;
steady;


model_diagnostics;

shocks;
 var A;
 periods  
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
;
 values 
0.026096974
0.0259943961631
0.0258922645397905
0.0257905771890424
0.0256893321782701
0.0255885275832946
0.0254881614883073
0.0253882319858332
0.0252887371766948
0.025149715822223
0.0250114590852007
0.0248739627602321
0.0247372226650509
0.0246012346403931
0.0244659945498709
0.0243314982798466
0.0241977417393075
0.0240647208597413
0.0239324315950127
0.0238008699212401
0.0236700318366733
0.0235399133615716
0.023410510538083
0.0232818194301235
0.0231538361232578
0.0230265567245799
0.0228999773625947
0.0227740941871005
0.0226489033690714
0.0225244011005415
0.0224005835944886
0.0222774470847189
0.0221549878257529
0.0220332020927113
0.0219120861812014
0.0217916364072048
0.0216718491069651
0.0215527206368768
0.021434247373374
0.0213164257128204
0.0211992520713999
0.0210827228850072
0.0209668346091397
0.0208515837187894
0.0207369667083361
0.0206229800914402
0.0205096204009373
0.0203968841887322
0.0202847680256941;
end;
steady;
check;

perfect_foresight_setup(periods=50);
perfect_foresight_solver;
rplot e;
rplot y;
rplot k;
rplot r;
rplot lambdda_2;
