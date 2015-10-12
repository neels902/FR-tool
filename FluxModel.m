function S=FluxModel(data, Bfield, Yparam)

% CREATES BFIELD VALUES IN AN OUTPUT STRUCTURE TO THE SIZE OF THE ARRAY
% FOUND IN INPUT DATA. BFIELD AND YPARAM ARE FREE PARAMETERS
%
%
% DESCRIPTION: routine creates flux rope of same length size as array in
% input, data. free param B0 and Y0 are properties of flux rope and s/c
% flyby.
%
%
% ARGUMENTS:
%          
% I:    data,       bfield values. (only interested in length of array).
% I:    Bfield,     max Bfield value. usually labelled B0.
% I:    Yparam,     Y0 parameter. desribes how close S/C passes through
%                   centre of rope. usually -0.5< Y0 < 0.5
%
% O:    S,          output structure containing Bx, By, Bz, Bmag
%                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Space and Atmospheric Physics Group
% The Blackett Laboratory - Imperial College London
% Neel Savani 31/01/08
% modified add round in L63 28/01/2011



%%
%FREE PARAMETERS
B0=Bfield;
Y0=Yparam;
                                                                                                                                                                                                                                               
%INPUT DATA
%define time in seconds
startT= datenum(data(1,1:6));
stepT=  datenum(data(2,1:6))- startT;
endT=   datenum(data(end,1:6));


%%%%%check no nans were between 1st nad 2nd data set%%%%%%%%%
stepT2=  datenum(data(3,1:6))- datenum(data(2,1:6)); 
stepT3=  datenum(data(4,1:6))- datenum(data(3,1:6));
stepT4=  datenum(data(5,1:6))- datenum(data(4,1:6));
stepT5=  datenum(data(21,1:6))- datenum(data(20,1:6)); % arbitrary large

%ordered= sort([ stepT stepT2 stepT3 stepT4]);
ordered= sort([ stepT stepT2 stepT3 stepT4 stepT5]);

stepT= ordered(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%# OF ROWS OF DATA POINTS ie FULL DIAMETER OF ROPE & DEFINE MODEL SIZES 
T= CountSec(stepT);
T= round(T);
t1_t0= CountSec( (endT-startT)+ stepT); %+step T is to add 1 row back in 
t1_t0= round(t1_t0);

L=round((t1_t0)/ T);    % do not use length(data) as nan have been removed reducing the array size.


%%
%INITIATE ROPE VARIABLES
mBmin=zeros(L,1);mBint=mBmin;mBmax=mBmin;mBmag=mBmin;
time=zeros(L,1); 
R0=L/2;
alpha= 2.4/R0; % defining Bz=0 at edge of rope.

%%
%FLUX MODEL
for i=1:1:L
    
    %as s/c passes through rope, x changes incremently; y remains fixed.
    x=(i-R0);
    y=(Y0*R0);
    r= sqrt(x^2 + y^2);
     if r==0
         r=0.0000001;
     end
     
     
    mBmin(i)=B0*  besselj(1,(alpha* r)) *y/r;
    mBmax(i)=B0*  besselj(1,(alpha* r)) *x/r;
    mBint(i)=B0*  besselj(0,(alpha* r));
    mBmag(i)= sqrt(mBmin(i)^2 + mBint(i)^2 + mBmax(i)^2);

    
    time(i,1)= startT + ( (i-1) * stepT );
    
    
end

%%
time= datevec(time);
%STRUCTURE OUTPUT S.Bz= AXIAL DIRECTION
S.time= time;
S.Bmin= mBmin;
S.Bint= mBint;
S.Bmax= mBmax;
S.Bmag= mBmag;

%%
%{
COMMAND WINGOW PLOTTING CODE

a=zeros(1000,1);
BfieldModel=FluxModel(a);
for i=1:1:1000
t(i)=i;
T=t';
end


subplot(2,2,1),plot(T,BfieldModel.Bmag),ylabel('B_{mag} (nT)','FontSize',11);
subplot(2,2,2),plot(T,BfieldModel.Bx),ylabel('B_{x} (nT)','FontSize',11);
subplot(2,2,3),plot(T,BfieldModel.By),ylabel('B_{y} (nT)','FontSize',11);
subplot(2,2,4),plot(T,BfieldModel.Bz),ylabel('B_{z} (nT)','FontSize',11);


%}
%%

return