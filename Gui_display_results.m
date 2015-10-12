
% optimised parameters
B0=sprintf('%#3.3g',handles.FR.B0);
set(handles.ed_B0,'string',B0);
set(handles.ed_Y0,'string',sprintf('%#3.2g',handles.FR.Y0));
set(handles.ed_Ch,'string',sprintf('%#.5s',handles.FR.H));
set(handles.ed_Rm,'string',sprintf('%#3.2g',handles.FR.check_chi_sqd));


% MC axis orientation using intvec MVA
ax1=sprintf('%#3.2g',handles.FR.MVA.intvec(1));
set(handles.axis1,'string',ax1);
ax2=sprintf('%#3.2g',handles.FR.MVA.intvec(2));
set(handles.axis2,'string',ax2);
ax3=sprintf('%#3.2g',handles.FR.MVA.intvec(3));
set(handles.axis3,'string',ax3);

% min variance direction
set(handles.edit11,'string',sprintf('%#3.2g',handles.FR.MVA.minvec(1)));
set(handles.edit12,'string',sprintf('%#3.2g',handles.FR.MVA.minvec(2)));
set(handles.edit13,'string',sprintf('%#3.2g',handles.FR.MVA.minvec(3)));

% max variance direction
set(handles.edit8,'string',sprintf('%#3.2g',handles.FR.MVA.maxvec(1)));
set(handles.edit9,'string',sprintf('%#3.2g',handles.FR.MVA.maxvec(2)));
set(handles.edit10,'string',sprintf('%#3.2g',handles.FR.MVA.maxvec(3)));

% eigen value ratios
set(handles.edit15,'string',sprintf('%#3.1f',(handles.FR.MVA.int ./ handles.FR.MVA.min)));
set(handles.edit16,'string',sprintf('%#3.1f',(handles.FR.MVA.max ./ handles.FR.MVA.int)));


% FR fit start and end times
st_time=handles.FR.MODEL.mtime(1,:);
en_time=handles.FR.MODEL.mtime(end,:);
ST=datestr(datenum(st_time),'dd,mmm,yyyy HH:MM');
EN=datestr(datenum(en_time),'dd,mmm,yyyy HH:MM');
set(handles.ed_St,'string',ST);
set(handles.ed_En,'string',EN);

