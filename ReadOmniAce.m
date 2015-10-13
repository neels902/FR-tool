function [ OUTPUT ] = ReadOmniAce(fileToRead1, IN_time)

% UrlStart= 'http://spdf.gsfc.nasa.gov/pub/data/ace/merged/4_min_merged_mag_plasma/ace_m';

UrlStart= fileToRead1;
arrTime=IN_time(1);

AceBegTime=arrTime - datenum([0,0,20,00,00,00]);  % reads data prior to arrival Time
AceEndTime=arrTime + datenum([0,0,20,00,00,00]);
temp=datevec(arrTime);
ArrTime2=temp(1);  % only need year
BT = num2str(ArrTime2);
ET='.dat';
WebUrl= [UrlStart,BT,ET];
temp = webread(WebUrl);
data=textscan(temp, '%n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n','delimiter','\t');

temp=length(data{1,8});
year=ArrTime2 .* ones(temp,1);
doy=data{1,2};
[dom,mon]=doy2dom(doy,year);
hr=data{1,3};
min=data{1,4};
ss=zeros(temp,1);
t=datenum([year,mon,dom,hr,min,ss]);
    pointsa= t>AceBegTime ;
    pointsb= t<AceEndTime;
    pointsc= double(pointsa) .* double(pointsb);
    loga= logical(pointsc);
t=t(loga,:);

% Bmag=data{1,8};
Bx=data{1,9};
Bx=Bx(loga,1);
 By=data{1,10};
 By=By(loga,1);
Bz=data{1,11};
Bz=Bz(loga,1);

clear data year doy dom mon hr min ss
a= [t, Bx,By,Bz];
OUTPUT=a;


end


