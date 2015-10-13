function OUTPUT = AveNanB (Idata, Iincre)

tol = 10^-9; % tolerance for floating point

time=Idata(:,1);
Bfield=Idata(:,2:4);    
% Bfield=Idata;

incre=Iincre; % = datenum of time increment value - let it be 12min

temp=time(1:floor(end./2),1)-time(1,1);

temp2=find(abs(temp-incre) < tol);

Num=temp2-1;
% NperDay=temp2-1;
% Num= tau* NperDay;

% find surplus data ponts at the end of the array which should be removed.
% ie if an extra few hours of day are provied at end of long array
ncut= rem((length(Bfield)),Num);


Bfield=Bfield(1:end-ncut,:);
time=time(1:end-ncut,:);

Nshap=ceil(length(Bfield(:,1))./Num);
bxtemp=reshape(Bfield(:,1),[Num,Nshap]);
bx=nanmean(bxtemp,1);

  bytemp=reshape(Bfield(:,2),[Num,Nshap]);
  by=nanmean(bytemp,1);

bztemp=reshape(Bfield(:,3),[Num,Nshap]);
bz=nanmean(bztemp,1);

ShapeT=reshape(time(:,1),[Num,Nshap]);
ShapeTime=nanmean(ShapeT,1);

%% output
OUTPUT=[ShapeTime',bx',by',bz'];




end



