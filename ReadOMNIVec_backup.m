function [ OUTPUT ] = ReadOMNIVec(fileToRead1, IN_time)

% Used inside TOPTREEBzTool > Bestimate > ave1day_preCarrot

%'http://iswa.ccmc.gsfc.nasa.gov/IswaSystemWebApp/DatabaseDataStreamServlet?format=JSON&resource=ACE,ACE,ACE&quantity=B_x,B_y,B_z&begin-time=2013-01-01%2023:59:59&end-time=2013-01-02%2023:59:59'
% &begin-time=2013-01-01%2023:59:59&end-time=2013-01-02%2023:59:59'

% ftp://spdf.gsfc.nasa.gov/pub/data/ace/merged/4_min_merged_mag_plasma/ace_m2003.dat

% fileToRead1='http://spdf.gsfc.nasa.gov/pub/data/ace/merged/4_min_merged_mag_plasma/ace_m'
% IN_time= 2001;      % year only otheriwse error
% [ OUTPUT ] = ReadOMNIVec(fileToRead1, IN_time);

UrlStart= fileToRead1;
arrTime=IN_time(1);



%% Create complete JSON url string
%%%NEW%%% -->
AceBegTime=arrTime- datenum([0,0,6,00,00,00]);  % reads data prior to arrival Time
AceEndTime=arrTime+ datenum([0,0,2,00,00,00]);
%%%%%%%%% <--

%BTst='begin-time=';
%ETst='&end-time=';
% tempst='%20';

% 2013-01-02%2023:59:59
% BTa=datestr(AceBegTime,'YYYY-mm-dd');
% BTb=datestr(AceBegTime,'HH:MM:SS');
% BT=[BTa,tempst,BTb];
BT = num2str(arrTime);
% 
% ETa=datestr(AceEndTime,'YYYY-mm-dd');
% ETb=datestr(AceEndTime,'HH:MM:SS');
% ET=[ETa,tempst,ETb];
ET='.dat';

%% import DATA from ONLINE API
% WebUrl= [UrlStart,BTst,BT,ETst,ET];
WebUrl= [UrlStart,BT,ET];
temp = webread(WebUrl);
data=textscan(temp, '%n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n','delimiter','\t');
%%
% a = zeros(length(data),4);
% ttim= datenum([0,0,0,0,1,0]);

Bmag=data{1,8};
Bx=data{1,9};
By=data{1,10};
Bz=data{1,11};

year=arrTime .* ones(length(Bmag),1);
doy=data{1,2};
[dom,mon]=doy2dom(doy,year);
hr=data{1,3};
min=data{1,4};
ss=zeros(length(Bmag),1);

t=datenum([year,mon,dom,hr,min,ss]);

clear data year doy dom mon hr min ss

a= [t, Bx,By,Bz,Bmag];
% a(a(:,2)<(-900),2)= NaN;
% a(a(:,3)<(-900),3)= NaN;
% a(a(:,4)<(-900),4)= NaN;

OUTPUT=a;
end

