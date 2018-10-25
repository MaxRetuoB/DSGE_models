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
    %iottta=0;
    %lambdda_2=0;
        
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
0.0256893321782700
0.0255885275832946
0.0254881614883073
0.0253882319858332
0.0252887371766948
0.0251896751699762
0.0250910440829868
0.0249928420412258
0.0248950671783464
0.0247977176361206
0.0247007915644035
0.0246042871210984
0.0245082024721216
0.0244125357913679
0.0243172852606754
0.0242224490697915
0.0241280254163379
0.0240340125057768
0.0239404085513767
0.0238472117741782
0.0237544204029605
0.0236620326742076
0.0235700468320748
0.0234784611283553
0.023387273822447
0.0232964831813193
0.0232060874794806
0.0231160849989449
0.0230264740291994
0.0229372528671724
0.0228484198172002
0.0227599731909954
0.0226719113076146
0.0225842324934265
0.0224969350820801
0.022410017414473
0.02232347783872
0.0222373147101216
0.0221515263911326
0.0220661112513312
0.0219810676673879
0.0218963940230347
0.0218120887090345
0.0217281501231502
0.0216445766701145;
end;
steady;
check;

perfect_foresight_setup(periods=300);
simul(periods=1000);
perfect_foresight_solver;
rplot e;
rplot y;
rplot k;
rplot r;
rplot A;
rplot lambdda_2;