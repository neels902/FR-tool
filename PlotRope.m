function S = PlotRope (data, Input_Coord, Input_colour)

% USING FULL DATA SET OF PLOTTED DATA, ROUTINE WILL ASKS TO TO DEFINE CME
% RANGE USING A CURSOR ON THE GRAPH. IT WILL THEN PROCEED TO FIT THE
% OPTIMISED FLUX ROPE. OUTPUT A STUCTURE OF RELEVENT MODEL DATA.
%
%
% DESCRIPTION: USE THIS ROUTIINE AS TOP TREE ROUTINE F0R CREATING
% EXPANDING FLUX ROPE. INPUT DATA MUST CONTAINING TIME INTERVAL OR CME WITH
% RELEVENT B-FIELD DATA  
%
% model limitataion only works if there is one section of nans. see L170
%
% ARGUMENTS:
%          
% I:  data,      contains 6 col for time and 4 col of Bfield data in S/C
%                frame of CME. time interval of data must contain the CME.
%                
%
% O:  S,         strucure containing: B0, Y0, R0, T0, fval, U, H, MVA, MODEL
% 
%
% See also, MVA, ExpandFluxModel, Project2Vardirn, TimeInterval, fminsearch, 
%           LSF_ExpandRope, ExpandFluxModel, Project2InvVardirn, car2sph,
%           subpanel.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Space and Atmospheric Physics Group
% The Blackett Laboratory - Imperial College London
% Neel Savani 21/03/08
% modified 28/07/08, modified int vector from MVA to make RH
% modified 28/07/08, modified min vector to force it to hemisphere defined
% as +ve x direction.
% modified 29/09/08, automated chirality. and fixed Nan data gap problem -
% model would always plot shorten rope than chosen from graph.
% modified 27/4/2010 problem if >2 section of nans if large rope in VEX, fixed
% modified 20/12/2010 problem with chirality if flipz=1 change made in ...
% chirality section L193
% modified 15/08/2011 redefine coord system by including as input into fn
% file- this was required for lb gui system
% modified 15/08/2011 redefine colour by including as input into fn file -
% this was required for the lb gui system.

% mag=sqrt( S.Bfield(:,2).^2 + S.Bfield(:,3).^2 + S.Bfield(:,4).^2 );
% data=[datevec(S.Bfield(:,1)),S.Bfield(:,2:4),mag];


%% DEFINE COORDINATE SYSTEM
%reply= input('define coordinate system: VSO=1; RTN=0; default=0 ?   :');
% if isempty(reply)
%     reply = 0;
% end
% RTN=0, VSO=1;
reply=Input_Coord;  % L200 pu_rtn_Callback
if Input_Coord == 'RTN'
    reply= 0;
elseif Input_Coord == 'VSO'
    reply=1;
else
    error('incompatible option for RTN or VSO')
end

%% DEFINE INPUT
time= data(:,1:6);
bx= data(:,7); 
by= data(:,8); 
bz= data(:,9);
bmag= data(:,10); 


% %% FULL DATA SET
% % eliminate NaN d=data
% logi= isfinite (data(:,7));
% dtime=time(logi,:);
% dbx=bx(logi,:);
% dby=by(logi,:);
% dbz=bz(logi,:);
% dbmag=bmag(logi,:);
% db=[dbx dby dbz];
% data=[dtime db dbmag] ;

%% CME DATA SET
%define CME time interval BY CLICKING ON GRAPH
figure(gcf)
[x,y]= ginput(2);
%[x(1,1),x(1,2)]= TimeInterval; % or by manually inputting the date
StartTime= x(1);
EndTime  = x(2);
if EndTime< StartTime
    StartTime= x(2);
    EndTime  = x(1);
end

datenum1=datenum(time);
pointsa= datenum1>StartTime ;
pointsb= datenum1<EndTime;
pointsc= double(pointsa) .* double(pointsb);
points1= logical(pointsc);

%points1= datenum1>StartTime & datenum1<EndTime;

ctime=time(points1,:);
cdBx=bx(points1,:);
cdBy=by(points1,:);
cdBz=bz(points1,:);
cdBmag=bmag(points1,:);
cdBnonNan=[cdBx cdBy cdBz]; % set data for fminsearch
cdata=[ctime cdBnonNan cdBmag];

% find array points for nan 
temp= isnan (cdBx);
temp2= find(double(temp)>0.4);
if isempty(temp2)==1
    startnan=0;
else
    startnan= temp2(1); % row number-  % if start and length known everything we need is known only if one section of Nans
end

nanarray= cdBx(temp);

%reduced CME range (without NaN) for MVA analysis
logic= isfinite (cdBx);

cdB=cdBnonNan(logic,:); % set data for fminsearch
cdBx=cdB(:,1);
cdBy=cdB(:,2);
cdBz=cdB(:,3);

cdata=cdata(logic,:) ;
cdBmag=cdata(:,10);

%% PERFORM MVA:   
% SETUP VARIABLES FOR MVA: DEFINE LOGICAL FOR PLOTING RANGE c=CME
% MVA ANALYSIS outputs RH system of vectors (x,y,z)=(min,int,max)
Z = MVA(cdB);

maxi=Z.maxvec;
int=Z.intvec;
mini=Z.minvec;
% check to see x is +ve VSO/RTN (defn by data) direction
flipx=0;
if mini(1,1)<0
    mini=-mini;     % rotates the MVA vectors
    maxi=-maxi;
    flipx=1;
end

%% ROTATE DATE INTO MVA FRAME
%modified 28/08/08.

[rcdBmin, rcdBint, rcdBmax]=Project2Vardirn (cdB, mini, int, maxi);
[RopeBmin, RopeBint, RopeBmax]=Project2Vardirn (cdBnonNan, mini, int, maxi); % set data for fminsearch

%define intermediate direction is +ve
%%% use flip variable to know how to rotate back into s/c frame
point= abs(rcdBint) == max(abs(rcdBint)); %logical vector to find position of max value
flipz=0;
if rcdBint(point)< 0    % use logical 'point' above to find if the value is +ve or -ve
    rcdBmax=-rcdBmax;           % modified no longer use x- as is now defined as +ve
    rcdBint=-rcdBint;
    RopeBmax=-RopeBmax;           % set data for fminsearch
    RopeBint=-RopeBint;
    
    flipz=1;
end
%% MVA axes with physical limitations, min=+ve VSO; int=+ve along axis
%OUTPUT STRUCTURE Z2
Z2.max=Z.max;
Z2.int=Z.int;
Z2.min=Z.min;
if flipz==1 && flipx==1
    Z2.minvec=-mini;
    Z2.intvec=-int;
    Z2.maxvec=Z.maxvec;
elseif flipz==1
    Z2.minvec=Z.minvec;
    Z2.intvec=-int;
    Z2.maxvec=-maxi;
elseif flipx==1 % put the vectors back to original form, MVA not interested in x being radially away/towards 
    Z2.minvec=-mini;
    Z2.intvec=Z.intvec;
    Z2.maxvec=-maxi;
else
    Z2.minvec=Z.minvec;
    Z2.intvec=Z.intvec;
    Z2.maxvec=Z.maxvec;
end

%% rotated CME DATA SET for fminsearch
rcdBmag= sqrt(  (RopeBmin).^2 + (RopeBint).^2 + (RopeBmax).^2  );
temp= length(rcdBmag);


% if isempty(temp2)<0.5
%     rcdBmin= [ rcdBmin(1:(startnan-1)) ;nanarray   ; rcdBmin(startnan:temp)];
%     rcdBint= [ rcdBint(1:(startnan-1)) ;nanarray   ; rcdBint(startnan:temp)];
%     rcdBmax= [ rcdBmax(1:(startnan-1)) ;nanarray   ; rcdBmax(startnan:temp)];
%     rcdBmag= [ rcdBmag(1:(startnan-1)) ;nanarray   ; rcdBmag(startnan:temp)];
% end

rcdata=[ctime RopeBmin RopeBint RopeBmax rcdBmag];


%% OPTIMISE ROPE PARAMETERS / INTIALISE FREE PARAMETERS

%DEFINE CHIRALITY
%%%%%%%%%%%%%%%
%H=-1;                % NOTE -1 MEANS RIGHT HANDED in VSO, stereoB event uses -1
%Chiral='Left Handed ';
%%%%%%%%%%%%%%%%     %      +1 MEANS LEFT HANDED

[H, Chiral]= DefineChiral(rcdBmax, reply);   % H=1 for RH MC in RTN coord    -- not true or     LH (VSO)
                                             % H=-1 for LH (in RTN)          -- not true  and     RH (VSO)

%% OPTIMISE MODEL

% DEFINE FREE VARIABLES
B0= 10; Y0=0.2; 
param= [B0, Y0];

options= optimset('MaxIter', 1e8, 'Tolx', 1e-4, 'Display', 'final');
[params,fval]=fminsearch(@LSF_Rope, param,options, rcdata, logic, H);


%% ROTATE OPTIMISED CME ROPE INTO S/C FRAME 

U=FluxModel(cdata,params(1),params(2));
mtime=U.time;
mtime=mtime(logic,:);

mBmin= U.Bmin(logic,:);
mBint= U.Bint(logic,:);
mBmax= U.Bmax(logic,:);


%% helicity >FLIP > InvMVA   ==> MVA frame 2 S/C frame

% CHANGE HELICITY
if H== -1
    mBmin=-mBmin;
    mBmax=-mBmax;
end



%% FLIP Z to counter-act above move int direction
if flipz== 1
    mBmax=-mBmax;
    mBint=-mBint;
end

mmB=[ mBmin mBint mBmax];


%% ROTATE RESULTS MVA  - inversion of MVA + FLIP to counter-act above move min direction
[rmBx, rmBy, rmBz]=Project2InvVardirn (mmB, mini, int, maxi);
rmBmag= sqrt(  (rmBx).^2 + (rmBy).^2 + (rmBz).^2  );




%% check fval is same in MVA frame as in S/C frame.
ResCheck=  (cdBx - rmBx).^2 + (cdBy - rmBy).^2 + (cdBz - rmBz).^2;
SumOResCheck= sum(ResCheck);
Rcheck=SumOResCheck/(length(cdBx));
fval_check=sqrt(Rcheck);
% old method of residual check
%RMScheck= sqrt(  (cdBx - rmBx).^2 + (cdBy - rmBy).^2 + (cdBz - rmBz).^2);
%fval_check=sum(RMScheck)/(3* length(rmBx));
tempBmag=sqrt(cdBx .^2 + cdBy.^2 + cdBz.^2);
ResCheck2=  ((cdBx./tempBmag) - (rmBx./rmBmag)).^2 +...
            ((cdBy./tempBmag) - (rmBy./rmBmag)).^2 +...
            ((cdBz./tempBmag) - (rmBz./rmBmag)).^2;
SumOResCheck2= sum(ResCheck2);
fval_check_norm=SumOResCheck2/(length(cdBx));



%% PLOT RESULTS ONTO CURRENT GRAPH

mB=[mtime, rmBx, rmBy, rmBz, rmBmag];
[mtheta,mphi,mr]=cart2sph(mB(:,7),mB(:,8),mB(:,9));
mtheta=(mtheta/(2*pi)*360 );
mphi=mphi/(2*pi)*360;

%%%%%% INPUT VERTICAL STACK SIZE
%n=input('Number of vertical stacks:');
n=6;
%%%%%%

% delete previous rope model on stack plot. useful if trying multiple
% start and end points
%{
if exist('sub1', 'var')==0
else
delete(sub1,sub2,sub3,sub4,sub5,sub6);
end

hold on;
sub1=subpanel(n,1,1),hold on ,plot(datenum(mB(:,1:6)),mB(:,7), 'Color', 'black', 'LineWidth', 2);
sub2=subpanel(n,1,2),hold on ,plot(datenum(mB(:,1:6)),mB(:,8), 'Color', 'black', 'LineWidth', 2);
sub3=subpanel(n,1,3),hold on ,plot(datenum(mB(:,1:6)),mB(:,9), 'Color', 'black', 'LineWidth', 2);
sub4=subpanel(n,1,4),hold on ,plot(datenum(mB(:,1:6)),mtheta , 'Color', 'black', 'LineWidth', 2);
sub5=subpanel(n,1,5),hold on ,plot(datenum(mB(:,1:6)),mphi   , 'Color', 'black', 'LineWidth', 2);
sub6=subpanel(n,1,6),hold on ,plot(datenum(mB(:,1:6)),mB(:,10),'Color', 'black', 'LineWidth', 2);

set(sub1,'Color', 'black', 'LineWidth', 2)
%}

if Input_colour==1
    FRCOL=[0.75, 0, 0.75]; % purple
elseif Input_colour==2
    FRCOL=[0, 0.5, 0.]; % dark green
elseif Input_colour==3
    FRCOL=[1, 0.69, 0.39]; % orange
elseif Input_colour==4
    FRCOL=[0, 0, 0];  % black
else
    error('incompatible option for colour ie not the first 4 options')
end

H(1)=subpanel(n,1,1);hold on ,plot(datenum(mB(:,1:6)),mB(:,7), 'Color', FRCOL, 'LineWidth', 2);
H(2)=subpanel(n,1,2);hold on ,plot(datenum(mB(:,1:6)),mB(:,8), 'Color', FRCOL, 'LineWidth', 2);
H(3)=subpanel(n,1,3);hold on ,plot(datenum(mB(:,1:6)),mB(:,9), 'Color', FRCOL, 'LineWidth', 2);
H(4)=subpanel(n,1,4);hold on ,plot(datenum(mB(:,1:6)),mtheta , 'Color', FRCOL, 'LineWidth', 2);
H(5)=subpanel(n,1,5);hold on ,plot(datenum(mB(:,1:6)),mphi   , 'Color', FRCOL, 'LineWidth', 2);
H(6)=subpanel(n,1,6);hold on ,plot(datenum(mB(:,1:6)),mB(:,10),'Color', FRCOL, 'LineWidth', 2);
  %{
elseif Input_colour==2
  
%colour dark green
H(1)=subpanel(n,1,1);hold on ,plot(datenum(mB(:,1:6)),mB(:,7), 'Color', [0, 0.5, 0.], 'LineWidth', 2);
H(2)=subpanel(n,1,2);hold on ,plot(datenum(mB(:,1:6)),mB(:,8), 'Color', [0, 0.5, 0.], 'LineWidth', 2);
H(2)=subpanel(n,1,3),hold on ,plot(datenum(mB(:,1:6)),mB(:,9), 'Color', [0, 0.5, 0.], 'LineWidth', 2);
H(2)=subpanel(n,1,4),hold on ,plot(datenum(mB(:,1:6)),mtheta , 'Color', [0, 0.5, 0.], 'LineWidth', 2);
H(2)=subpanel(n,1,5),hold on ,plot(datenum(mB(:,1:6)),mphi   , 'Color', [0, 0.5, 0.], 'LineWidth', 2);
H(2)=subpanel(n,1,6),hold on ,plot(datenum(mB(:,1:6)),mB(:,10),'Color', [0, 0.5, 0.], 'LineWidth', 2);
elseif Input_colour==3
%colour orange
    subpanel(n,1,1),hold on ,plot(datenum(mB(:,1:6)),mB(:,7), 'Color', [1, 0.69, 0.39], 'LineWidth', 2);
    subpanel(n,1,2),hold on ,plot(datenum(mB(:,1:6)),mB(:,8), 'Color', [1, 0.69, 0.39], 'LineWidth', 2);
    subpanel(n,1,3),hold on ,plot(datenum(mB(:,1:6)),mB(:,9), 'Color', [1, 0.69, 0.39], 'LineWidth', 2);
    subpanel(n,1,4),hold on ,plot(datenum(mB(:,1:6)),mtheta , 'Color', [1, 0.69, 0.39], 'LineWidth', 2);
    subpanel(n,1,5),hold on ,plot(datenum(mB(:,1:6)),mphi   , 'Color', [1, 0.69, 0.39], 'LineWidth', 2);
    subpanel(n,1,6),hold on ,plot(datenum(mB(:,1:6)),mB(:,10),'Color', [1, 0.69, 0.39], 'LineWidth', 2);
elseif Input_colour==4
%color black
    subpanel(n,1,1),hold on ,plot(datenum(mB(:,1:6)),mB(:,7), 'Color', 'black', 'LineWidth', 2);
    subpanel(n,1,2),hold on ,plot(datenum(mB(:,1:6)),mB(:,8), 'Color', 'black', 'LineWidth', 2);
    subpanel(n,1,3),hold on ,plot(datenum(mB(:,1:6)),mB(:,9), 'Color', 'black', 'LineWidth', 2);
    subpanel(n,1,4),hold on ,plot(datenum(mB(:,1:6)),mtheta , 'Color', 'black', 'LineWidth', 2);
    subpanel(n,1,5),hold on ,plot(datenum(mB(:,1:6)),mphi   , 'Color', 'black', 'LineWidth', 2);
    subpanel(n,1,6),hold on ,plot(datenum(mB(:,1:6)),mB(:,10),'Color', 'black', 'LineWidth', 2);
else
    error('incompatible option for colour ie not the first 4 options')
end
%}    
    
%% OUTPUT STRUCTURE

S.B0= params(1);
S.Y0= params(2);
S.H= Chiral;
S.MVA=Z2;  % defined as RH coord system, with int vector for +ve axial field, min vector for +ve x st towards(away) the sun for VSO (RTN)
S.flipx= flipx;
S.flipz= flipz;
S.fval= fval;
S.check= fval_check;
S.check_chi_sqd= fval_check_norm;


S.MODEL.rmBx=rmBx;
S.MODEL.rmBy=rmBy;
S.MODEL.rmBz=rmBz;
S.MODEL.rmBmag=rmBmag;
S.MODEL.mtheta=mtheta;
S.MODEL.mphi=mphi;
S.MODEL.mtime=mtime;



%%
return

