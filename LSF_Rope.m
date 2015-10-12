function [RMS]= LSF_Rope (param, data, L, Helicity )

% GENERATES RMS FROM MODEL BFIELD RESULTS IN MVA FRAME FROM THE CME DATA
% RANGE AND PARAM GIVEN. THERE ARE 4 FREE PARAMETERS, B0, Y0, R0, U, T0.
%
%
% DESCRIPTION: WITH THE FREE PARAMETERS AND TIME/BFIELD DATA, THE ROUTINE
% COMPARES CME DATA IN MVA FRAME WITH MODEL. 
% WRITTEN IN A FORMAT THAT CAN BE USED WITH OPTIMISATION ROUTINE-FMINSEARCH
%
%
% ARGUMENTS:
%          
% I:  param,          contains to free parameters: B0, Y0, R0, T0.
% I:  data,           contains 6 col for time and 4 col of Bfield data
%                     (NaN's removed) in MVA frame of CME time interval
%
% O:  RMS,            root mean square for Bfield 
%
% See also, FluxModel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Space and Atmospheric Physics Group
% The Blackett Laboratory - Imperial College London
% Neel Savani 20/03/08
% modified LSF 


% INPUT PARAMETERS
B0=param(1);
Y0=param(2);

logic=L; % a logical to remove data rows of nans from model rows

dat= data(logic,:);
time=dat(:,1:6);
rdBmin=dat(:,7);
rdBint=dat(:,8);
rdBmax=dat(:,9);

H= Helicity; 


%%
%%%%%%%%%  MODEL %%%%%%%%%

Z=FluxModel(data, B0, Y0);

mtime=Z.time;
if H==1
    mBmin=Z.Bmin;
    mBmax=Z.Bmax;
else 
    mBmin=-Z.Bmin;
    mBmax=-Z.Bmax;
end
mBint=Z.Bint;
mBmag=Z.Bmag;
mB=[mBmin mBint mBmax];
cmodel=[mtime mB mBmag];


%eliminate nan lines in model in order to compare with least squares.
cmodel= cmodel(logic,:);
% l= least square fit
lmBmin=cmodel(:,7);
lmBint=cmodel(:,8);
lmBmax=cmodel(:,9);


%%
 %LEAST SQUARE FIT
% normalise the b vectors
rdBmin=dat(:,7);
rdBint=dat(:,8);
rdBmax=dat(:,9);
rdBmag= sqrt(rdBmin.^2 + rdBint.^2 + rdBmax.^2);
lmBmag= sqrt(lmBmin.^2 + lmBint.^2 + lmBmax.^2);
 
% RMS= sqrt(  (rdBmin - lmBmin).^2 + (rdBint - lmBint).^2 + (rdBmax - lmBmax).^2);
% RMS=sum(RMS)/(3* length(rdBmin));
residual=  (rdBmin - lmBmin).^2 + (rdBint - lmBint).^2 + (rdBmax - lmBmax).^2;
SumOfResidual= sum(residual);
R=SumOfResidual/(length(rdBmin));
RMS=sqrt(R);


%%
return
