% Demo for delay embedding
% This demo inverts a model of a linear oscillatory system, which operates
% with delays, i.e. its evolution function is of the form:
%   x(t+1) = f(x(t-delay)),
% where the delay can be specific to the entry of the state vector x.
% VBA_NLStateSpaceModel.m uses embedding to model such delayed dynamical
% systems. This means it augments the state vector x with past instances of
% it, i.e.:
%   X(t) = [    x(t)
%               x(t-1)
%               ...
%               x(t-max(delays)) ]
% Then the embedding evolution function is such that:
%   X(t+1) = [  x(t+1)              = [ f(x(t-delay))
%               x(t)                    x(t)
%               ...                     ...
%               x(t-max(delays)+1) ]    x(t-max(delays)+1) ]
%          =  [ f(x(t-delay))
%               A*X(t)          ]
% where:
% - A is simply a zero matrix with ones on the dim.n+1 ^th diagonal
% - f(x(t-delay)) is a compact notation for heterogeneous delays, i.e.:
% f(x(t-delay)) = [ f_1(x_1(t-D11),...,x_n(t-D1n))
%                   f_2(x_1(t-D21),...,x_n(t-D2n))
%                   ...
%                   f_n(x_1(t-Dn1),...,x_n(t-Dnn)  ]
% Thus, one has to specify a full delay matrix D, whose i^th row contains
% the delays applied to each state when deriving the evolution of the i^th
% state.


clear variables
close all

% Choose basic settings for simulations
n_t = 1e2;
delta_t = 1e0;         % integration time step (Euler method)
f_fname = @f_lin2D;
g_fname = @g_Id;
u       = [];

% Build options structure for temporal integration of SDE
inF.deltat = delta_t/4;
inF.a           = 0.1;
inF.b           = 0.5e0; % decay rate
options.decim   = 4;
options.inF     = inF;
options.delays = [[1,5];[4,1]];
options.backwardLag = 4;
% options.checkGrads = 1;

% Parameters of the simulation
alpha   = 1e1;
sigma   = 1e3;
theta   = 3;
phi     = [];

% Build priors for model inversion
priors.muX0 = [-2;-2];
priors.SigmaX0 = 1e-1*eye(2);
priors.muTheta = 0*ones(1,1);
priors.SigmaTheta = 1e2*eye(1);
priors.a_alpha = 1e0;
priors.b_alpha = 1e-1;
priors.a_sigma = 1e0;
priors.b_sigma = 1e-3;

% Build options and dim structures for model inversion
options.priors      = priors;
dim.n_theta         = 1;
dim.n_phi           = 0;
dim.n               = 2;

% Build time series of hidden states and observations
[y,x,x0,eta,e] = simulateNLSS(n_t,f_fname,g_fname,theta,phi,u,alpha,sigma,options);

% display time series of hidden states and observations
displaySimulations(y,x,eta,e)


% Call inversion routine
% [posterior,out] = VBA_onlineWrapper(y,u,f_fname,g_fname,dim,options);
[posterior,out] = VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options);

% Display results
displayResults(posterior,out,y,x,x0,theta,phi,alpha,sigma)


% Compare with no delay embedding
hfp = findobj('tag','VBNLSS');
set(hfp,'tag','0');
options.delays= [];
[posterior2,out2] = VBA_NLStateSpaceModel(y,u,f_fname,g_fname,dim,options);



