function [ytrend,ycycle]=one_sided_hp_filter_kalman(y,lambda,x_user,P_user,discard)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% one_sided_hp_filter_kalman.m - a one-sided HP filter derived using the
%        Kalman filter to optimally one-sidedly filter the series that renders 
%       the standard two-sided HP filter optimal.
%      
%       Input:  y - a Txn data matrix, where T is the number of observations
%                       on n variables  (i.e., data is assumed to be in column
%                       format). 
%                   lambda - a scalar. This is a smoothing parameter. Optional: if not entered,
%                        a default value of 1600 will be used.
%                   x_user - a 2xn matrix with initial values of the state
%                       estimate for each variable in y. The underlying
%                       state vector is 2x1m hence two values are needed
%                       for each variable in y. Optional: if not entered,
%                        default backwards extrapolations based on the
%                        first two observations will be used.
%                   P_user - a structural array with n elements, each a two
%                       2x2 matrix of intial MSE estimates for each
%                       variable in y.  Optional: if not entered,
%                        default matrix with large variances used.
%                   discard  -  a scalar. The first discard periods will be
%                       discarded resulting in output matrices of size
%                       (T-discard)xn. Optional: if not entered, a default
%                       value of 0 will be used.
%
%       Output: ytrend - a (T-discard)xn matrix of extracted trends for
%                       each of the n variables.
%                   ycycle a  (T-discard)xn matrix of deviations from the extracted trends for
%                       each of the n variables. Optional.
%
%       Usage examples:
%       [ytrend]=one_sided_hp_filter_kalman(y)
%                   will yield the Txn matrix of trends using the data in
%                   y with lambda set to 1600
%
%       [ytrend,ycycle]=one_sided_hp_filter_kalman(y,[],[],[],discard)
%                   will yield two (T-discard)xn matrices containing the last T-discard periods of trends and deviations 
%                   using the data in y with lambda set to its default 1600
%
%
%       The method implements the procedure described on p. 301 of Stock,
%       J.H. and M.W. Watson (1999). "Forecasting inflation," Journal of Monetary Economics,  vol. 44(2), pages 293-335, October.
%
%       "The one-sided HP trend estimate is constructed as the Kalman
%       filter estimate of tau_t in the model:
%       
%       y_t=tau_t+epsilon_t
%       (1-L)^2 tau_t=eta_t"
%
%
%Copyright: Alexander Meyer-Gohde
%
%You are free to use/modify/redistribute this program so long as original
%authorship credit is given and you in no way impinge on its free
%distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2 || isempty(lambda),  lambda = 1600; end%If the user didn't provide a value for lambda, set it to the default value 1600
[T,n] = size (y);% Calculate the number of periods and the number of variables in the series

%Kalman preliminaries. The notation follows Chapter 13 of Hamilton, J.D.
%(1994). Time Series Analysis. with the exception of H, which is equivalent
%to his H'.
q=1/lambda; %the signal-to-noise ration: i.e. var eta_t / var epsilon_t
F=[2,-1;1,0];% The state transition matrix
H=[1,0]; % The observation matrix
Q=[q,0;0,0]; % The variance-covariance matrix of the errors in the state equation
R=1;%The variance of the error in the observation equation

for k=1:n %Run the Kalman filter for each variable
if nargin < 4 || isempty(x_user), x=[2*y(1,k)-y(2,k); 3*y(1,k)-2*y(2,k)]; else x=x_user(:,k);end %If the user didn't provide an intial value for state estimate, extrapolate back two periods from the observations
if nargin < 4 || isempty(P_user), P= [1e5 0;0 1e5]; else P=P_user{k}; end %If the user didn't provide an intial value for the MSE, set a rather high one

  for j=1:T %Get the estimates for each period
       [x,P]=kalman_update(F,H,Q,R,y(j,k),x,P); %Get an estimate of the state using the the new observation
       ytrend(j,k)=x(2);%The second element of the state is the estimate of the trend
  end
end

if nargout==2%Should the user have requested a second output
    ycycle=y-ytrend;%The second output will be the deviations from the HP trend
end

if nargin==5,%If the user provided a discard parameter
    ytrend=ytrend(discard+1:end,:);%Remove the first "discard" periods from the trend series
    if nargout==2%Should the user have requested a second output
        ycycle=ycycle(discard+1:end,:);%The second output will be the deviations from the HP trend, likewise with  first "discard" periods removed
    end
end
end

function   [x,P]=kalman_update(F,H,Q,R,obs,x,P)
   %%%%
   %
   % Updates the Kalman filter estimation of the state and MSE
   % See Chapter 13 of Hamilton, J.D. (1994). Time Series Analysis. Princeton University Press.
   %
   %%%%

S = H*P*H'+R; %Subsidiary calculation
K=F*P*H';%Subsidiary calculation
K=K/S; %Kalman gain
x=F*x+K*(obs -H*x); %State estimate
Temp=F-K*H;%Subsidiary calculation
P=Temp*P*Temp';%Subsidiary calculation
P=P+Q+K*R*K';%MSE estimate
end