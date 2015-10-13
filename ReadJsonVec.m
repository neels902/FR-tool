function [ OUTPUT ] = ReadJsonVec(fileToRead1, IN_time)

% Used inside TOPTREEBzTool > Bestimate > ave1day_preCarrot

%'http://iswa.ccmc.gsfc.nasa.gov/IswaSystemWebApp/DatabaseDataStreamServlet?format=JSON&resource=ACE,ACE,ACE&quantity=B_x,B_y,B_z&begin-time=2013-01-01%2023:59:59&end-time=2013-01-02%2023:59:59'
% &begin-time=2013-01-01%2023:59:59&end-time=2013-01-02%2023:59:59'

UrlStart= fileToRead1;
arrTime=IN_time(1);



%% Create complete JSON url string
%%%NEW%%% -->
AceBegTime=arrTime- datenum([0,0,4,00,00,00]);  % reads data prior to arrival Time
AceEndTime=arrTime+ datenum([0,0,4,00,00,00]);
%%%%%%%%% <--

BTst='begin-time=';
ETst='&end-time=';
tempst='%20';

% 2013-01-02%2023:59:59
BTa=datestr(AceBegTime,'YYYY-mm-dd');
BTb=datestr(AceBegTime,'HH:MM:SS');
BT=[BTa,tempst,BTb];

ETa=datestr(AceEndTime,'YYYY-mm-dd');
ETb=datestr(AceEndTime,'HH:MM:SS');
ET=[ETa,tempst,ETb];

%% import DATA from ONLINE API
WebUrl= [UrlStart,BTst,BT,ETst,ET];
data = webread(WebUrl);

%%
a = zeros(length(data),4);
ttim= datenum([0,0,0,0,1,0]);

for ii=1:1:length(data),
    javaSerialDate=data(ii).timestamp;
%     TimNum=AceBegTime + (ii-1)*ttim;
    
    a(ii,1)=datenum([1970 1 1 0 0 javaSerialDate / 1000]);
    a(ii,2)=data(ii).B_x;
    a(ii,3)=data(ii).B_y;
    a(ii,4)=data(ii).B_z;
end

a(a(:,2)<(-900),2)= NaN;
a(a(:,3)<(-900),3)= NaN;
a(a(:,4)<(-900),4)= NaN;

OUTPUT=a;
end

