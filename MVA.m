function S = MVA(data)

% Creates MVA vectors and values from given data set - 27/01/08
%
% DESCRIPTION: With an input of Bfield data in 3 vectors[x,y,z], this
% routine outputs a structure containing the MVA eigen vectors and
% associated eigen values. [min max int] are in RH system of [x y z]. min
% vector is defined to point in hemisphere of +ve x ie in VSO- towards the
% sun; RTN- vector points away from the sun.
%
% cross(min,int)=max   ...for RH system
%
% ARGUMENTS:
%
% I data     cartesian vector of Bfield (3 vectors: [x y z])
%
% O S       Structure containing MVA evectors and evalues.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Space and Atmospheric Physics Group
% The Blackett Laboratory - Imperial College London
% N. Savani 27/01/08
% modified 29/08/08


%data=6col of time 4col of Bfield data
Bfield=data;
M=length(Bfield);

%% CONSTRUCT CO-VARIANT MATRIX AND OBTAIN EIGENVALUES
cv=cov(Bfield);

[V,D]=eig(cv);
evalues= diag(D);

a=D(1);
avec=V(:,1);
b=evalues(2);
bvec=V(:,2);
c=evalues(3);
cvec=V(:,3);

%% SORT THE EIGENVALUES WITH CORRESPONDING EIGENVECTORS INTO ORDER TO
% DETERMINE MAXIMUM, INTERMEDIATE AND MINIMUM VARIANCE DIRECTIONS

if a>b   
    d=a;
    dvec=avec;
    j=b;
    jvec=bvec;   
else    
    d=b;
    dvec=bvec;
    j=a;
    jvec=avec;    
end
if d>c 
    eig1=d;
    maxi=dvec;   
    if j>c   
        eig2=j;
        int=jvec;
        eig3=c;
        mini=cvec;      
    else       
        eig2=c;
        int=cvec;
        eig3=j;
        mini=jvec;        
    end  
else   
    eig1=c;
    maxi=cvec;
    eig2=d;
    int=dvec;
    eig3=j;
    mini=jvec;   
end

% was commented out reintroduced 20/12/2010
%modified 29/08/08
%check for right handed system
if dot(maxi,cross(mini,int))<0.5
   maxi=-maxi;
end

%% CREATE OUTPUT STRUCTURE

S.max=eig1;
S.maxvec=maxi;
S.int=eig2;
S.intvec=int;
S.min=eig3;
S.minvec=mini;

return
