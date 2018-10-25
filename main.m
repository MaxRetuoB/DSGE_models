%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script reproduces Maxime Bouter results for its first chapter thesis
% maxime.bouter@univ-pau.fr 
% maxime.bouter@gmail.com

clear all;
close all;
%% First we have to load the .csv file real_gdp.csv.
% if this command does not work, load the file manually:
realgdp1 = importfile('real_gdp.csv', 1, 91);
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%
%% The SCRIPT START HERE:
%%%%%%%%%%%%%%%%%%%%%%%%%
% we apply a one-sided kalman filter to detrend the time series:
%let's first do it for the real gdp time series:
real_gdp = table2array(realgdp1(2:90,2));

[ytrend,ycycle]=one_sided_hp_filter_kalman(real_gdp,1600);


%% we do the same manipulation but for the real price of oil:
real_oil = table2array(realgdp1(2:90,3));
[oiltrend,oilcycle]=one_sided_hp_filter_kalman(real_oil,1600);

%% finally we do the same for the consumption expenditures:
real_cons = table2array(realgdp1(2:90,4));
[constrend,conscycle]=one_sided_hp_filter_kalman(real_cons,1600);

%% If we need to save the results and to reuses it later:
ut_rate=table2array(realgdp1(2:90,5));

detrend_hp_series=[ytrend ycycle oiltrend oilcycle constrend conscycle ut_rate];
detrend_hp_series= array2table(detrend_hp_series,'VariableNames',{'gdp_trend','y','oil_trend','oil_cycle','cons_trend','c','u'});
%we then create a excel file with all these results
fileName='detrend_hp.xlsx';
writetable(detrend_hp_series,'detrend_hp.xlsx');

%% The 2nd step is to estimate the autoregressive processes for both exogenous shocks:

plot(conscycle)
figure

autocorr(oilcycle,80)
%AR(1) estimation for the real oil time series

Mdl=arima(1,0,0);
Mdl.Constant = 0;
EstMdl=estimate(Mdl,oilcycle)


% Estimation of the AR(1) gives rho=.72476 and standard dev=0.0536


%% We now have to estimate the AR(1) for the technology progress:
cons_gdp = table2array(realgdp1(2:88,6));
hours=table2array(realgdp1(2:88,7));
cap_net=table2array(realgdp1(2:88,8));
ene=table2array(realgdp1(2:88,9));
ut=table2array(realgdp1(2:88,5));

tfp=cons_gdp./(hours.^0.63.*(cap_net.*ut).^0.3.*ene.^0.04);

[tfptrend,tfpcycle]=one_sided_hp_filter_kalman(tfp,1600);
plot(tfpcycle)
figure
plot(tfptrend)
figure
autocorr(tfpcycle,80)


%AR(1) estimation for the TFP:

Mdl=arima(1,0,0);
Mdl.Constant = 0;
EstMdl=estimate(Mdl,tfpcycle)

%rho_z=0.89581 and standarderror=0.035272

%%
[cap_nettrend,cap_netcycle]=one_sided_hp_filter_kalman(cap_net,1600);

var(cap_netcycle)
mean(cap_netcycle)
%% next we call dynare the first time
% we first estimate using a bayesian dsge 
% several parameters such as the coefficient of 
%correlation for the technology shock
% the standard deviation and so forth and so on
%
%in a 2nd step we create several variables, and we will
%use them later to compare 2 models

dynare dsge_quotas1.mod

y_irf_z1=oo_.irfs.y_eps_z(1,1:80);
l_irf_z1=oo_.irfs.l_eps_z(1,1:80);
k_irf_z1=oo_.irfs.k_eps_z(1,1:80);
u_irf_z1=oo_.irfs.u_eps_z(1,1:80);
deltta_irf_z1=oo_.irfs.deltta_eps_z(1,1:80);
i_irf_z1=oo_.irfs.i_eps_z(1,1:80);
E_irf_z1=oo_.irfs.E_eps_z(1,1:80);
e_irf_z1=oo_.irfs.e_eps_z(1,1:80);
c_irf_z1=oo_.irfs.c_eps_z(1,1:80);
r_irf_z1=oo_.irfs.r_eps_z(1,1:80);
w_irf_z1=oo_.irfs.w_eps_z(1,1:80);
z_irf_z1=oo_.irfs.z_eps_z(1,1:80);
pe_irf_z1=oo_.irfs.pe_eps_z(1,1:80);
lambdda_1_irf_z1=oo_.irfs.lambdda_1_eps_z(1,1:80);
%lambdda_2_irf_z1=oo_.irfs.lambdda_2_eps_z(1,1:80);

y_irf_p1=oo_.irfs.y_eps_pe(1,1:80);
l_irf_p1=oo_.irfs.l_eps_pe(1,1:80);
k_irf_p1=oo_.irfs.k_eps_pe(1,1:80);
u_irf_p1=oo_.irfs.u_eps_pe(1,1:80);
deltta_irf_p1=oo_.irfs.deltta_eps_pe(1,1:80);
i_irf_p1=oo_.irfs.i_eps_pe(1,1:80);
e_irf_p1=oo_.irfs.e_eps_pe(1,1:80);
E_irf_p1=oo_.irfs.E_eps_pe(1,1:80);
c_irf_p1=oo_.irfs.c_eps_pe(1,1:80);
r_irf_p1=oo_.irfs.r_eps_pe(1,1:80);
w_irf_p1=oo_.irfs.w_eps_pe(1,1:80);
z_irf_p1=oo_.irfs.z_eps_pe(1,1:80);
pe_irf_p1=oo_.irfs.pe_eps_pe(1,1:80);
lambdda_1_irf_p1=oo_.irfs.lambdda_1_eps_pe(1,1:80);
%lambdda_2_irf_p1=oo_.irfs.lambdda_2_eps_pe(1,1:80);

%if we want to obtain the argmax for k
[argvalue_kz1, argmax_kz1] = max(k_irf_z1);
[argvalue_uz1, argmin_uz1] = min(u_irf_z1);
[argvalue_k1p1, argmin_kp1] = min(k_irf_p1);

%% 2nd model
close all;

dynare dsge_quotas2.mod
close all;

y_irf_z2=oo_.irfs.y_eps_z(1,1:80);
l_irf_z2=oo_.irfs.l_eps_z(1,1:80);
k_irf_z2=oo_.irfs.k_eps_z(1,1:80);
i_irf_z2=oo_.irfs.i_eps_z(1,1:80);
e_irf_z2=oo_.irfs.e_eps_z(1,1:80);
E_irf_z2=oo_.irfs.E_eps_z(1,1:80);
c_irf_z2=oo_.irfs.c_eps_z(1,1:80);
r_irf_z2=oo_.irfs.r_eps_z(1,1:80);
w_irf_z2=oo_.irfs.w_eps_z(1,1:80);
z_irf_z2=oo_.irfs.z_eps_z(1,1:80);
pe_irf_z2=oo_.irfs.pe_eps_z(1,1:80);
lambdda_1_irf_z2=oo_.irfs.lambdda_1_eps_z(1,1:80);
%lambdda_2_irf_z2=oo_.irfs.lambdda_2_eps_z(1,1:80);

[argvalue_kz2, argmax_kz2] = max(k_irf_z2);

y_irf_p2=oo_.irfs.y_eps_pe(1,1:80);
l_irf_p2=oo_.irfs.l_eps_pe(1,1:80);
k_irf_p2=oo_.irfs.k_eps_pe(1,1:80);
i_irf_p2=oo_.irfs.i_eps_pe(1,1:80);
e_irf_p2=oo_.irfs.e_eps_pe(1,1:80);
E_irf_p2=oo_.irfs.E_eps_pe(1,1:80);
c_irf_p2=oo_.irfs.c_eps_pe(1,1:80);
r_irf_p2=oo_.irfs.r_eps_pe(1,1:80);
w_irf_p2=oo_.irfs.w_eps_pe(1,1:80);
z_irf_p2=oo_.irfs.z_eps_pe(1,1:80);
pe_irf_p2=oo_.irfs.pe_eps_pe(1,1:80);
lambdda_1_irf_p2=oo_.irfs.lambdda_1_eps_pe(1,1:80);
%lambdda_2_irf_p2=oo_.irfs.lambdda_2_eps_pe(1,1:80);

%% 3rd model: (as in Fisher and sprignborn,
% totality of the capital stock is used in production


close all;
dynare dsge_quotas3.mod
close all;
y_irf_z3=oo_.irfs.y_eps_z(1,1:80);
l_irf_z3=oo_.irfs.l_eps_z(1,1:80);
k_irf_z3=oo_.irfs.k_eps_z(1,1:80);
i_irf_z3=oo_.irfs.i_eps_z(1,1:80);
e_irf_z3=oo_.irfs.e_eps_z(1,1:80);
E_irf_z3=oo_.irfs.E_eps_z(1,1:80);
c_irf_z3=oo_.irfs.c_eps_z(1,1:80);
r_irf_z3=oo_.irfs.r_eps_z(1,1:80);
w_irf_z3=oo_.irfs.w_eps_z(1,1:80);
z_irf_z3=oo_.irfs.z_eps_z(1,1:80);
pe_irf_z3=oo_.irfs.pe_eps_z(1,1:80);
lambdda_1_irf_z3=oo_.irfs.lambdda_1_eps_z(1,1:80);
%lambdda_2_irf_z3=oo_.irfs.lambdda_2_eps_z(1,1:80);

y_irf_p3=oo_.irfs.y_eps_pe(1,1:80);
l_irf_p3=oo_.irfs.l_eps_pe(1,1:80);
k_irf_p3=oo_.irfs.k_eps_pe(1,1:80);
i_irf_p3=oo_.irfs.i_eps_pe(1,1:80);
e_irf_p3=oo_.irfs.e_eps_pe(1,1:80);
E_irf_p3=oo_.irfs.E_eps_pe(1,1:80);
c_irf_p3=oo_.irfs.c_eps_pe(1,1:80);
r_irf_p3=oo_.irfs.r_eps_pe(1,1:80);
w_irf_p3=oo_.irfs.w_eps_pe(1,1:80);
z_irf_p3=oo_.irfs.z_eps_pe(1,1:80);
pe_irf_p3=oo_.irfs.pe_eps_pe(1,1:80);
lambdda_1_irf_p3=oo_.irfs.lambdda_1_eps_pe(1,1:80);
%lambdda_2_irf_z3=oo_.irfs.lambdda_2_eps_z(1,1:80);

%% lets create a csv file with all our results
%shock_z1=[y_irf_z1' l_irf_z1' k_irf_z1' u_irf_z1' deltta_irf_z1' ...
%          i_irf_z1' E_irf_z1' e_irf_z1' c_irf_z1' ...
%          r_irf_z1' w_irf_z1' z_irf_z1' pe_irf_z1'  ...
%           ];
%csvwrite('shock_z1',shock_z1)

%shock_p1=[y_irf_p1' l_irf_p1' k_irf_p1' u_irf_p1' deltta_irf_p1' ...
%          i_irf_p1' E_irf_p1' e_irf_p1' c_irf_p1' ...
%          r_irf_p1' w_irf_p1' z_irf_p1' pe_irf_p1' ...
%           ];     
%csvwrite('shock_p1',shock_p1)

%shock_z2=[y_irf_z2' l_irf_z2' k_irf_z3' i_irf_z2' E_irf_z2' e_irf_z2' ...
%          c_irf_z2' r_irf_z2' w_irf_z2' z_irf_z2' pe_irf_z2'...
%           ];
%csvwrite('shock_z2',shock_z2)

%shock_p2=[y_irf_p2' l_irf_p2' k_irf_p2' i_irf_p2' E_irf_p2' e_irf_p2' ...
%          c_irf_p2' r_irf_p2' w_irf_p2' z_irf_p2' pe_irf_p2' ...
%           ];
%csvwrite('shock_p2',shock_p2)
  
%% impulse responses functions for TFP shock:
time=1:80;
   figure('Name','Impulse response function to technology shock') 
    subplot(4,3,1)
    plot(time',z_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',z_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',z_irf_z3*100,'g-','Linewidth',1.2)
    
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    legend('\delta(u)','\delta, u=0.81')
    title('$z$','interpreter','latex','Fontsize',8)
    xlabel('Periods','interpreter','latex','Fontsize',8)
    
    
    subplot(4,3,2)
    plot(time',y_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',y_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',y_irf_z3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$y$','interpreter','latex','Fontsize',8)
    
    
    subplot(4,3,3)
    plot(time',k_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',k_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',k_irf_z3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$k$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,4)
    plot(time',r_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',r_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',r_irf_z3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$r$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,5)
    plot(time',i_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',i_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',i_irf_z3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$i$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,6)
    plot(time',deltta_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$\delta(u)$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,7)
    plot(time',u_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$u$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,8)
    plot(time',e_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',e_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',e_irf_z3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$e$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,9)
    plot(time',l_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',l_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',l_irf_z3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$l$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,10)
    plot(time',c_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',c_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',c_irf_z3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$c$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,11)
    plot(time',w_irf_z1,'k-.','Linewidth',1.2)
    hold on
    plot(time',w_irf_z2,'r--','Linewidth',1.2)
    hold on
    %plot(time',w_irf_z3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$w$','interpreter','latex','Fontsize',8)
    
    print -depsc tech_exo_shock.eps
    
%%%%%impulse responses functions for energy shock
%% k
time=1:80;
figure('Name','Impulse response function to energy price shock')

    subplot(4,3,1)
    plot(time',pe_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',pe_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',pe_irf_p3*100,'g-.','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    legend('\delta(u)','\delta, u=0.81')
    title('$p_e$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,2)
    plot(time',y_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',y_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',y_irf_p3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$y$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,3)
    plot(time',k_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',k_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',k_irf_p3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$k$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,4)
    plot(time',r_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',r_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',r_irf_p3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$r$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,5)
    plot(time',i_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',i_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',i_irf_p3*100,'g-','Linewidth',1.2)
    hold on 
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$i$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,6)
    plot(time',deltta_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$\delta(u)$','interpreter','latex','Fontsize',8)
    
    
    subplot(4,3,7)
    plot(time',u_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$u$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,8)
    plot(time',e_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',e_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',e_irf_p3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$e$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,9)
    plot(time',l_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',l_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',l_irf_p3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$l$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,10)
    plot(time',c_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',c_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',c_irf_p3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$c$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,11)
    plot(time',w_irf_p1,'k-.','Linewidth',1.2)
    hold on
    plot(time',w_irf_p2,'r--','Linewidth',1.2)
    hold on
    %plot(time',w_irf_p3*100,'g-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,80)],'k','LineWidth',0.2)
    title('$w$','interpreter','latex','Fontsize',8)
    
   print -depsc ener_price_exo_shock.eps

 %% Perfect foresight :
close all;
%Number of variables to plot 10
%y,k,r,i,delta, u, e, l, c, w
nx=10;
%number of policy to compare
nk=4;
%duration of the policy: 48 quarters
ny=50;
%Matrices
yy=zeros(ny,nk);
kk=zeros(ny,nk);
rr=zeros(ny,nk);
ii=zeros(ny,nk);
dd=zeros(ny,nk);
uu=zeros(ny,nk);
ee=zeros(ny,nk);
ll=zeros(ny,nk);
cc=zeros(ny,nk);
ww=zeros(ny,nk);
lambddaa_2=zeros(ny,nk);

dynare dsge_BAU.mod
close all;
yy(1:50,1)=y(1:50,1)
yy(1:50,1)=y(1:50,1);
kk(1:50,1)=k(1:50,1);
rr(1:50,1)=r(1:50,1);
ii(1:50,1)=i(1:50,1);
dd(1:50,1)=deltta(1:50,1);
uu(1:50,1)=u(1:50,1);
ee(1:50,1)=e(1:50,1);
ll(1:50,1)=l(1:50,1);
cc(1:50,1)=c(1:50,1);
ww(1:50,1)=w(1:50,1);
lambddaa_2(1:50,1)=oo_.endo_simul(13,1:50)';

dynare dsge_pefer2.mod
close all;
yy(1:50,2)=y(1:50,1);
kk(1:50,2)=k(1:50,1);
rr(1:50,2)=r(1:50,1);
ii(1:50,2)=i(1:50,1);
dd(1:50,2)=deltta(1:50,1);
uu(1:50,2)=u(1:50,1);
ee(1:50,2)=e(1:50,1);
ll(1:50,2)=l(1:50,1);
cc(1:50,2)=c(1:50,1);
ww(1:50,2)=w(1:50,1);
lambddaa_2(1:50,2)=oo_.endo_simul(13,1:50)';
dynare dsge_pefer3.mod
close all;
yy(1:50,3)=y(1:50,1);
kk(1:50,3)=k(1:50,1);
rr(1:50,3)=r(1:50,1);
ii(1:50,3)=i(1:50,1);
dd(1:50,3)=deltta(1:50,1);
uu(1:50,3)=u(1:50,1);
ee(1:50,3)=e(1:50,1);
ll(1:50,3)=l(1:50,1);
cc(1:50,3)=c(1:50,1);
ww(1:50,3)=w(1:50,1);
lambddaa_2(1:50,3)=oo_.endo_simul(13,1:50)';

dynare dsge_pefer4.mod
close all;
yy(1:50,4)=y(1:50,1);
kk(1:50,4)=k(1:50,1);
rr(1:50,4)=r(1:50,1);
ii(1:50,4)=i(1:50,1);
dd(1:50,4)=deltta(1:50,1);
uu(1:50,4)=u(1:50,1);
ee(1:50,4)=e(1:50,1);
ll(1:50,4)=l(1:50,1);
cc(1:50,4)=c(1:50,1);
ww(1:50,4)=w(1:50,1);
lambddaa_2(1:50,4)=oo_.endo_simul(13,1:50)';
%% carbon price
time=1:49;
plot(time',lambddaa_2(1:49,1),'k-','Linewidth',1.2)
    hold on
    plot(time',lambddaa_2(1:49,2),'k-.','Linewidth',1.2)
    %axis([0 50 0.63 0.665])
    hold on
    plot(time',lambddaa_2(1:49,3),'k--','Linewidth',1.2)
    hold on
    plot(time',lambddaa_2(1:49,4),'k:','Linewidth',1.2)
    title('carbon price','interpreter','latex','Fontsize',8)
print -depsc carbon_price.eps
%%
%economic impact:
time=1:49;
   figure('Name','Policy comparison') 
    subplot(4,3,1)
    plot(time',yy(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.63 0.67])
    hold on
    plot(time',yy(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',yy(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',yy(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    %legend('BAU','current policy','reform', 'shock')
    title('y','interpreter','latex','Fontsize',8)
   
  
    subplot(4,3,2)
    plot(time',kk(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 9.2 9.7])
    hold on
    plot(time',kk(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',kk(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',kk(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Capital stock','interpreter','latex','Fontsize',8)
    
    subplot(4,3,3)
    plot(time',rr(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.0275 0.0283])
    hold on
    plot(time',rr(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',rr(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',rr(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('rental rate','interpreter','latex','Fontsize',8)
    
    subplot(4,3,4)
    plot(time',ii(1:49,1),'k','Linewidth',1.2)
    axis([0 49 0.09 0.13])
    hold on
    plot(time',ii(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',ii(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',ii(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Investment','interpreter','latex','Fontsize',8)
    
    subplot(4,3,5)
    plot(time',dd(1:49,1),'k','Linewidth',1.2)
    axis([0 49 0.012 0.013])
    hold on
    plot(time',dd(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',dd(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',dd(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('$\delta(u)$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,6)
    plot(time',uu(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.795 0.815])
    hold on
    plot(time',uu(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',uu(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',uu(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('utilisation rate','interpreter','latex','Fontsize',8)
    
    subplot(4,3,7)
    
    plot(time',ee(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.02 0.027])
    hold on
    plot(time',ee(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',ee(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',ee(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Energy','interpreter','latex','Fontsize',8)
    
    subplot(4,3,8)
    plot(time',ll(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.21 0.225])
    hold on
    plot(time',ll(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',ll(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',ll(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Labour','interpreter','latex','Fontsize',8)
   
    subplot(4,3,9)
    
    plot(time',cc(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.525 0.54])
    hold on
    plot(time',cc(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',cc(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',cc(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Consumption','interpreter','latex','Fontsize',8)
    
    subplot(4,3,10)
    plot(time',ww(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 1.84 1.88])
    hold on
    plot(time',ww(1:49,2),'b-.','Linewidth',1.2)
    hold on
    plot(time',ww(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',ww(1:49,4),'r--','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Wage','interpreter','latex','Fontsize',8)
    
    subplot(4,3,11)
    %plot(time',yy(1:49,1)-cc(1:49,1),'k-','Linewidth',1.2)
    %axis([0 49 .09 .13])
    %hold on
    %plot(time',yy(1:49,2)-cc(1:49,2),'r-.','Linewidth',1.2)
    %hold on
    %plot(time',yy(1:49,3)-cc(1:49,3),'g--','Linewidth',1.2)
    %hold on
    %plot(time',yy(1:49,4)-cc(1:49,4),'b-','Linewidth',1.2)
    %hold on
    %plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    %title('saving','interpreter','latex','Fontsize',8)
   
    %subplot(4,3,12) 
    plot(time',lambddaa_2(1:49,1),'k-','Linewidth',1.2)
    hold on
    plot(time',lambddaa_2(1:49,2),'b-.','Linewidth',1.2)
    axis([0 49 0 0.3])
    hold on
    plot(time',lambddaa_2(1:49,3),'k.','Linewidth',1.2)
    hold on
    plot(time',lambddaa_2(1:49,4),'r--','Linewidth',1.2)
    title('carbon price','interpreter','latex','Fontsize',8)
   
    
    print -depsc policy_response.eps
  %% k  
 %compute some ratios:
 figure('Name','Ratios') 
    subplot(2,3,1)
    plot(time',yy(1:49,1)./kk(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.067 0.07])
    hold on
    plot(time',yy(1:49,2)./kk(1:49,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',yy(1:49,3)./kk(1:49,3),'g--','Linewidth',1.2)
    hold on
    plot(time',yy(1:49,4)./kk(1:49,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    %legend('BAU','current policy','reform', 'shock')
    title('capital productivity','interpreter','latex','Fontsize',8)
   
    
    subplot(2,3,2)
    plot(time',ee(1:49,1)./yy(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.03 0.045])
    hold on
    plot(time',ee(1:49,2)./yy(1:49,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ee(1:49,3)./yy(1:49,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ee(1:49,4)./yy(1:49,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('GDP energy intensity','interpreter','latex','Fontsize',8)
    
    subplot(2,3,3)
    
    plot(time',ee(1:49,1)./kk(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 2*10^-3 3*10^-3])
    hold on
    plot(time',ee(1:49,2)./kk(1:49,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ee(1:49,3)./kk(1:49,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ee(1:49,4)./kk(1:49,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Capital energy intensity','interpreter','latex','Fontsize',8)
    
    subplot(2,3,4)
    plot(time',ii(1:49,1)./yy(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.15 0.2])
    hold on
    plot(time',ii(1:49,2)./yy(1:49,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ii(1:49,3)./yy(1:49,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ii(1:49,4)./yy(1:49,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Investment rate','interpreter','latex','Fontsize',8)
    
    subplot(2,3,5)
    plot(time',cc(1:49,1)./yy(1:49,1),'k-','Linewidth',1.2)
    axis([0 49 0.8 0.84])
    hold on
    plot(time',cc(1:49,2)./yy(1:49,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',cc(1:49,3)./yy(1:49,3),'g--','Linewidth',1.2)
    hold on
    plot(time',cc(1:49,4)./yy(1:49,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,49)],'k','LineWidth',0.2)
    title('Consumtpion rate','interpreter','latex','Fontsize',8)
    
    subplot(2,3,6)
    plot(time',yy(1:49,1)./ll(1:49,1),'k-','Linewidth',1.2)
    %axis([0 49 2.925 2.98])
    hold on
    plot(time',yy(1:49,2)./ll(1:49,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',yy(1:49,3)./ll(1:49,3),'g--','Linewidth',1.2)
    hold on
    plot(time',yy(1:49,4)./ll(1:49,4),'b-','Linewidth',1.2)
    hold on 
    title('Labour productivity','interpreter','latex','Fontsize',8)
    
    
    print -depsc gdp_ratio.eps
%%
%economic impact:
time=1:49;
   figure('Name','Policy comparison') 
    subplot(4,3,1) 
    plot(time',yy(1:49,2)/yy(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.95 1.015])
    hold on
    plot(time',yy(1:49,3)/yy(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',yy(1:49,4)/yy(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    %legend('BAU','current policy','reform', 'shock')
    title('y','interpreter','latex','Fontsize',8)
   
    subplot(4,3,2)
    plot(time',kk(1:49,2)/kk(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.95 1.015])
    hold on
    plot(time',kk(1:49,3)/kk(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',kk(1:49,4)/kk(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('Capital stock','interpreter','latex','Fontsize',8)
    
    subplot(4,3,3)
    plot(time',rr(1:49,2)/rr(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.99 1.005])
    hold on
    plot(time',rr(1:49,3)/rr(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',rr(1:49,4)/rr(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('rental rate','interpreter','latex','Fontsize',8)
   
    subplot(4,3,4)
    plot(time',ii(1:49,2)/ii(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.8 1.1])
    hold on
    plot(time',ii(1:49,3)/ii(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',ii(1:49,4)/ii(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('Investment','interpreter','latex','Fontsize',8)
    
    subplot(4,3,5)
    plot(time',dd(1:49,2)/dd(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.975 1.01])
    hold on
    plot(time',dd(1:49,3)/dd(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',dd(1:49,4)/dd(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('$\delta(u)$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,6)
    plot(time',uu(1:49,2)/uu(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.985 1.005])
    hold on
    plot(time',uu(1:49,3)/uu(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',uu(1:49,4)/uu(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('utilisation rate','interpreter','latex','Fontsize',8)
    
    subplot(4,3,7)
    plot(time',ee(1:49,2)/ee(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.75 1.05])
    hold on
    plot(time',ee(1:49,3)/ee(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',ee(1:49,4)/ee(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('Energy','interpreter','latex','Fontsize',8)
    
    
    subplot(4,3,8)
    plot(time',ll(1:49,2)/ll(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.95 1.01])
    hold on
    plot(time',ll(1:49,3)/ll(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',ll(1:49,4)/ll(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('Labour','interpreter','latex','Fontsize',8)
   
    subplot(4,3,9)
    plot(time',cc(1:49,2)/cc(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.985 1.005])
    hold on
    plot(time',cc(1:49,3)/cc(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',cc(1:49,4)/cc(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('Consumption','interpreter','latex','Fontsize',8)
    
    subplot(4,3,10)
    plot(time',ww(1:49,2)/ww(1:49,1),'b-.','Linewidth',1.2)
    axis([0 49 0.985 1.005])
    hold on
    plot(time',ww(1:49,3)/ww(1:49,1),'k.','Linewidth',1.2)
    hold on
    plot(time',ww(1:49,4)/ww(1:49,1),'r--','Linewidth',1.2)
    hold on
    plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    title('Wage','interpreter','latex','Fontsize',8)
    
    %subplot(4,3,11)
    %hold on
    %plot(time',lambddaa_2(1:49,2)/lambddaa_2(1:49,1),'b-.','Linewidth',1.2)
    %axis([0 49 0.9 1.1])
    %hold on
    %plot(time',lambddaa_2(1:49,3)/lambddaa_2(1:49,1),'k.','Linewidth',1.2)
    %hold on
    %plot(time',lambddaa_2(1:49,4)/lambddaa_2(1:49,1),'r--','Linewidth',1.2)
    %plot(time,[1*ones(1,49)],'k','LineWidth',0.2)
    %title('carbon price','interpreter','latex','Fontsize',8)
   
    
    print -depsc policy_response_relative.eps
    return
    %% testbis
    dynare dsge_BAU.mod
close all;
yy(1:200,1)=y(1:200,1)
yy(1:200,1)=y(1:200,1);
kk(1:200,1)=k(1:200,1);
rr(1:200,1)=r(1:200,1);
ii(1:200,1)=i(1:200,1);
dd(1:200,1)=deltta(1:200,1);
uu(1:200,1)=u(1:200,1);
ee(1:200,1)=e(1:200,1);
ll(1:200,1)=l(1:200,1);
cc(1:200,1)=c(1:200,1);
ww(1:200,1)=w(1:200,1);
gg(1:200,1)=g(1:200,1);

dynare dsge_pefer2.mod
close all;
yy(1:200,2)=y(1:200,1);
kk(1:200,2)=k(1:200,1);
rr(1:200,2)=r(1:200,1);
ii(1:200,2)=i(1:200,1);
dd(1:200,2)=deltta(1:200,1);
uu(1:200,2)=u(1:200,1);
ee(1:200,2)=e(1:200,1);
ll(1:200,2)=l(1:200,1);
cc(1:200,2)=c(1:200,1);
ww(1:200,2)=w(1:200,1);
gg(1:200,2)=g(1:200,1);

dynare dsge_pefer3.mod
close all;
yy(1:200,3)=y(1:200,1);
kk(1:200,3)=k(1:200,1);
rr(1:200,3)=r(1:200,1);
ii(1:200,3)=i(1:200,1);
dd(1:200,3)=deltta(1:200,1);
uu(1:200,3)=u(1:200,1);
ee(1:200,3)=e(1:200,1);
ll(1:200,3)=l(1:200,1);
cc(1:200,3)=c(1:200,1);
ww(1:200,3)=w(1:200,1);
gg(1:200,3)=g(1:200,1);

dynare dsge_pefer4.mod
close all;
yy(1:200,4)=y(1:200,1);
kk(1:200,4)=k(1:200,1);
rr(1:200,4)=r(1:200,1);
ii(1:200,4)=i(1:200,1);
dd(1:200,4)=deltta(1:200,1);
uu(1:200,4)=u(1:200,1);
ee(1:200,4)=e(1:200,1);
ll(1:200,4)=l(1:200,1);
cc(1:200,4)=c(1:200,1);
ww(1:200,4)=w(1:200,1);
gg(1:200,4)=g(1:200,1);

%%
%economic impact:
time=1:200;
   figure('Name','Policy comparison') 
    subplot(4,3,1)
    plot(time',yy(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 0.645 0.67])
    hold on
    plot(time',yy(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',yy(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',yy(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    %legend('BAU','current policy','reform', 'shock')
    title('y','interpreter','latex','Fontsize',8)
   
  
    subplot(4,3,2)
    plot(time',kk(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 9.5 9.8])
    hold on
    plot(time',kk(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',kk(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',kk(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Capital stock','interpreter','latex','Fontsize',8)
    
    subplot(4,3,3)
    plot(time',rr(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 0.0277 0.028])
    hold on
    plot(time',rr(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',rr(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',rr(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('rental rate','interpreter','latex','Fontsize',8)
    
    subplot(4,3,4)
    plot(time',ii(1:200,1),'k','Linewidth',1.2)
    axis([0 200 0.11 0.135])
    hold on
    plot(time',ii(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ii(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ii(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Investment','interpreter','latex','Fontsize',8)
    
    subplot(4,3,5)
    plot(time',dd(1:200,1),'k','Linewidth',1.2)
    axis([0 200 0.0124 0.0126])
    hold on
    plot(time',dd(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',dd(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',dd(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('$\delta(u)$','interpreter','latex','Fontsize',8)
    
    subplot(4,3,6)
    plot(time',uu(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 0.805 0.812])
    hold on
    plot(time',uu(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',uu(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',uu(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('utilisation rate','interpreter','latex','Fontsize',8)
    
    subplot(4,3,7)
    
    plot(time',ee(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 0.0255 0.027])
    hold on
    plot(time',ee(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ee(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ee(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Energy','interpreter','latex','Fontsize',8)
    
    subplot(4,3,8)
    plot(time',ll(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 0.215 0.23])
    hold on
    plot(time',ll(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ll(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ll(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Labour','interpreter','latex','Fontsize',8)
   
    subplot(4,3,9)
    
    plot(time',cc(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 0.534 0.537])
    hold on
    plot(time',cc(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',cc(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',cc(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Consumption','interpreter','latex','Fontsize',8)
    
    subplot(4,3,10)
    plot(time',ww(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 1.87 1.88])
    hold on
    plot(time',ww(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ww(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ww(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Wage','interpreter','latex','Fontsize',8)
    
    subplot(4,3,11)
    plot(time',yy(1:200,1)-cc(1:200,1),'k-','Linewidth',1.2)
    axis([0 200 .11 .13])
    hold on
    plot(time',yy(1:200,2)-cc(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',yy(1:200,3)-cc(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',yy(1:200,4)-cc(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('saving','interpreter','latex','Fontsize',8)
   
    subplot(4,3,12)
    plot(time',gg(1:200,1),'k-','Linewidth',1.2)
    %axis([0 200 .1 .17])
    hold on
    plot(time',gg(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',gg(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',gg(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Public expenditure','interpreter','latex','Fontsize',8)
   
    print -depsc policy_response.eps
  %% k  
 %compute some ratios:
 figure('Name','Ratios') 
    subplot(2,3,1)
    plot(time',yy(1:200,1)./kk(1:200,1),'k-','Linewidth',1.2)
   % axis([0 200 0.066 0.07])
    hold on
    plot(time',yy(1:200,2)./kk(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',yy(1:200,3)./kk(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',yy(1:200,4)./kk(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    %legend('BAU','current policy','reform', 'shock')
    title('capital productivity','interpreter','latex','Fontsize',8)
   
    
    subplot(2,3,2)
    plot(time',ee(1:200,1)./yy(1:200,1),'k-','Linewidth',1.2)
    %axis([0 200 0.03 0.045])
    hold on
    plot(time',ee(1:200,2)./yy(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ee(1:200,3)./yy(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ee(1:200,4)./yy(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('GDP energy intensity','interpreter','latex','Fontsize',8)
    
    subplot(2,3,3)
    
    plot(time',ee(1:200,1)./kk(1:200,1),'k-','Linewidth',1.2)
    %axis([0 200 2*10^-3 3*10^-3])
    hold on
    plot(time',ee(1:200,2)./kk(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ee(1:200,3)./kk(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ee(1:200,4)./kk(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Capital energy intensity','interpreter','latex','Fontsize',8)
    
    subplot(2,3,4)
    plot(time',ii(1:200,1)./yy(1:200,1),'k-','Linewidth',1.2)
    %axis([0 200 0.14 0.2])
    hold on
    plot(time',ii(1:200,2)./yy(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',ii(1:200,3)./yy(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',ii(1:200,4)./yy(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Investment rate','interpreter','latex','Fontsize',8)
    
    subplot(2,3,5)
    plot(time',cc(1:200,1)./yy(1:200,1),'k-','Linewidth',1.2)
    %axis([0 200 0.76 0.83])
    hold on
    plot(time',cc(1:200,2)./yy(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',cc(1:200,3)./yy(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',cc(1:200,4)./yy(1:200,4),'b-','Linewidth',1.2)
    hold on
    plot(time,[0*ones(1,200)],'k','LineWidth',0.2)
    title('Consumtpion rate','interpreter','latex','Fontsize',8)
    
    subplot(2,3,6)
    plot(time',yy(1:200,1)./ll(1:200,1),'k-','Linewidth',1.2)
    %axis([0 200 2.925 2.98])
    hold on
    plot(time',yy(1:200,2)./ll(1:200,2),'r-.','Linewidth',1.2)
    hold on
    plot(time',yy(1:200,3)./ll(1:200,3),'g--','Linewidth',1.2)
    hold on
    plot(time',yy(1:200,4)./ll(1:200,4),'b-','Linewidth',1.2)
    hold on 
    title('Labour productivity','interpreter','latex','Fontsize',8)
    
    
    print -depsc gdp_ratio.eps

    