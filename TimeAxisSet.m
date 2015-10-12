function [ReturnHandle]=TimeAxisSet (time_type,keep_xlabels);
%
% EAL
% V 0.0  28-02-1996 M file to set x axis labels 
%   0.1  07-06-1996 Altered to distinguish between subplots and colourbar
%   (no x labels)
%   0.2  19-06-1996 Set of differents dxtick used according to xrange
%   1.0  02-04-1997 Function updated to MATLAB 5 - first label removed
%   2.0  02-05-1997 Function uses either decimal daynumber or seconds since 1950
%   2.0  07-06-1997 Bug fixed in s50 calculation
%   2.0  19-06-1997 Bug fixed in string selection
%   2.1  07-01-1998 Same time ranges used for ydd and s50
%   2.2     07-1998 Title_Date used for title determination
%   2.2     08-1998 Subplot handles returned and title handle
%   2.3  20-10-1998 Criterion for selecting colorbar changed to exmaination
%   of DeleteFcn (='Colorbar('delete')'for colorbars)  
%   2.4  02-11-1998 Method of sorting handles changed from sort to flipud 
%   2.5  12-11-1998 Ranges updated
%   2.6  13-11-1998 Option added to allow subpanels with different time
%                   ranges 
%   2.7  20-11-1998 Hour:min used instead of day:hour for 1 hour intervals
%   2.8  11-03-1999 Range of timescales extended to seconds - minimum x range
%                   now 1 second
%   2.9  27-04-1999 Colons removed from labels
%   2.91 19-10-2000 Title removed and information added to xlabel
%   3.0  05-02-2001 Additional timetypes added for DServe epoch format and
%                   matlab times
%   3.1  06-02-2001 Bug fixes for DServe epoch and matlab times
%   3.2  27-09-2001 Bug fixes in axis labelling and location of xticks 
%   4.0  12-02-2002 No longer assumes that TimeAxisSet with zero arguments has time_type='s50' 
%   4.1  13-02-2002 Bug fix in time_type determination
%   4.2  26-02-2002 Change label time to be derived from first tick mark instead of xlim(1)
%                   Bug fix in xlabel labelling when xtickmarks are at daynumbers
%   4.3  06-06-2002 Bug fix in 'mat' time_type determination
%   5.0  04-07-2002 Started removing dependence on any non DServe functions (time conversions)
%        09-07-2002 Remove time_types ydd and s50
%        10-07-2002 Remove title from plot and title handle from return arguments
%        23-09-2002 Bug fix in x axis label (take start time not end time)
%   5.1  15-10-2002 Bug fix in labelling for years
%   5.11 05-11-2002 Alter upper limit for dXsec=15 from 1.5 min to 1.9  
%   5.12 07-12-2002 Correct axes identification method - use same method as zm
%   6.0  27-03-2003 Change x axis label to include month and date as well
%                   as daynumber
%   6.1  04-04-2003 Extend usable range to > few years  
%   6.2  22-09-2003 Bug fix: include DSdate2mat and daycheck as local function to make TimeAxisSet
%                   standalone
%   6.3  23-12-2003 Bug fix in calculation of time ticks
%   6.4  14-01-2003 Alter range for undefined timetype
%   6.5  23-09-2004 Minor correction to handling of input arguments
%
% [handle] =TimeAxisSet (time_type,keep_xlabels);
%
% time_type    : 'dep' DServe epoch - seconds since 1900
%              : 'mat' Matlab time  - decimal days since 1900
%     
% keep_xlabels : subpanel handle if exists then does not delete x labels 
%                from all but bottom subpanel
%                  
%    
% handle    : array of subplot handles


if ~exist('keep_xlabels'),
  keep_xlabels=1;
  selhandle=0;
else
  selhandle=1;
  handle=keep_xlabels;
  keep_xlabels=0;
  nplot=1;
end

% Check number of arguments
% If nargin = 0 , calculate time_type
if nargin==0|isempty(time_type)|~exist('time_type','var'),
    calctt=1; 
else
    calctt=0;
end;

% If normal plot

% if ~selhandle,
%   handle=get(gcf,'Children');
%   nplot=size(handle,1);
%   
%   for n=1:nplot,    
%     
%     ans=get(handle(n),'Tag');
%     if length(ans>=3)&strcmp(ans(1:3),'Col')
%       handle(n)=NaN;
%     end
%   end
%   
%   handle=handle(~isnan(handle));
%   handle=flipud(handle);
%   nplot=size(handle,1);
%   
% end

% Identify axes for time axis to be applied to
% Do not apply to colorbar axes

if ~selhandle,
  ha=get(gcf,'Children');
  isaxis=zeros(1,length(ha));
  for i=1:length(ha)
    if strcmp(get(ha(i),'Type'),'axes')&...
        (isempty(strmatch('colorbar',get(ha(i),'DeleteFcn')))&~(strcmp(get(ha(i),'Tag'),'Colorbar'))),
      isaxis(i)=1;
    end
  end
  ha=ha(find(isaxis==1));
  handle=ha;
  handle=flipud(handle);
  nplot=size(handle,1);
end

% Check that all axis have the same length
for n=1:nplot
    XLimN(n,1:2)=get(handle(n),'XLim');
end
% Check to see if all limits are the same
if (sum(diff(XLimN(:,1))))|(sum(diff(XLimN(:,2))))
   XLimMax(1)=min(XLimN(:,1));
   XLimMax(2)=max(XLimN(:,2));
   for n=1:nplot
      set(get(handle(n),'YLabel'),'Units','normalized');
      set(handle(n),'XLim',XLimMax);
   end
end

% Calculate length of axis in minutes
% Find appropriate tick separation - 15, 60 sec, 5, 10, 20 min      
% 1, 3, 6, 12 hrs, 1,3 days
% Round start time to nearest tick mark 

for n=1:nplot,
  Xlim=get(handle(n),'Xlim');    
  
  if calctt,
      if (Xlim(1)<DSdate2mat(1974,1,0,0,0))
          time_type='und';
  elseif (Xlim(1)>DSdate2mat(1974,1,0,0,0))&(Xlim(1)<DSdate2mat(2050,1,0,0,0)),
          time_type='mat';
      else
          time_type='dep';
      end
  end
  
  switch time_type,
  case {'dep'}  
    
    % Xlength in seconds
    Xlength=(Xlim(2)-Xlim(1));
    
    [DateStart]=DStime2date(Xlim(1));
    [DateStop]=DStime2date(Xlim(2));
    yStart=DateStart(:,1);yStop=DateStop(:,1);
    dStart=DateStart(:,2);dStop=DateStop(:,2);
    hStart=DateStart(:,3);hStop=DateStop(:,3);
    mStart=DateStart(:,4);mStop=DateStop(:,4);
    sStart=DateStart(:,5);sStop=DateStop(:,5);
    
  case {'mat'}  
    
    % Xlength in seconds
    Xlength=(Xlim(2)-Xlim(1)).*86400;
    
    [MatStart]=DSmat2date(Xlim(1));
    [MatStop]=DSmat2date(Xlim(2));
    yStart=MatStart(:,1);yStop=MatStop(:,1);
    dStart=MatStart(:,2);dStop=MatStop(:,2);
    hStart=MatStart(:,3);hStop=MatStop(:,3);
    mStart=MatStart(:,4);mStop=MatStop(:,4);
    sStart=MatStart(:,5);sStop=MatStop(:,5); 
    
  end
  
  
  switch time_type,
      
  case {'dep','mat'}
    
    % Calculate Xlength in seconds. minutes, hours and days
    % Calculate dX in seconds
    
    XlengthS=Xlength;
    XlengthM=Xlength./60;
    XlengthH=Xlength./(60.*60);
    XlengthD=Xlength./(24.*60.*60);
    
    if XlengthM < 1,
      
      % Define dXsec
      
      if XlengthS<6,
        dXsec=1;
      elseif XlengthS>=6  & XlengthS<12,
        dXsec=2;
      elseif XlengthS>=12 & XlengthS<24,
        dXsec=4;
      elseif XlengthS>=24 & XlengthS<60,
        dXsec=10;
      end
      
      sft=dXsec-rem(sStart,dXsec);
      if ~(rem(sStart,dXsec)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart;s1=sStart+sft;
      if s1==60,s1=0;m1=m1+1;end
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXsec;
      timeflag=0;
      
    elseif XlengthM<1.9,
      dXsec=15;
      sft=dXsec-rem(sStart,dXsec);
      if ~(rem(sStart,dXsec)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart;s1=sStart+sft;
      if s1==60,s1=0;m1=m1+1;end
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXsec;
      timeflag=1;
    elseif XlengthM>=1.9&XlengthM<3,
      dXsec=30;
      sft=dXsec-rem(sStart,dXsec);
      if ~(rem(sStart,dXsec)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart;s1=sStart+sft;
      if s1==60,s1=0;m1=m1+1;end
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      dX=dXsec;
      timeflag=1;
    elseif XlengthM>=3&XlengthM<8,
      dXmin=1;
      sft=dXmin-rem(mStart,dXmin);
      if ~(rem(mStart,dXmin)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart+sft;s1=0;
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXmin.*60;
      timeflag=2;
    elseif XlengthM>=8&XlengthM<15.5,
      dXmin=2;
      sft=dXmin-rem(mStart,dXmin);
      if ~(rem(mStart,dXmin)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart+sft;s1=0;
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXmin.*60;
      timeflag=2;
    elseif XlengthM>=15.5&XlengthM<31,
      dXmin=5;
      sft=dXmin-rem(mStart,dXmin);
      if ~(rem(mStart,dXmin)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart+sft;s1=0;
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXmin.*60;
      timeflag=2;
    elseif XlengthM>=31&XlengthM<61,
      dXmin=10;
      sft=dXmin-rem(mStart,dXmin);
      if ~(rem(mStart,dXmin)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart+sft;s1=0;
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXmin.*60;
      timeflag=2;
    elseif XlengthM>=61&XlengthM<(60.*2+1),
      dXmin=15;
      sft=dXmin-rem(mStart,dXmin);
      if ~(rem(mStart,dXmin)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart+sft;s1=0;
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXmin.*60;
      timeflag=2;
    elseif XlengthM>=(60.*2+1)&XlengthM<(60.*5+1),
      dXmin=30;
      sft=dXmin-rem(mStart,dXmin);
      if ~(rem(mStart,dXmin)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart;m1=mStart+sft;s1=0;
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXmin.*60;
      timeflag=2;
    elseif XlengthM>=(60.*5+1)&XlengthM<(60.*7+1),
      dXhour=1;
      sft=dXhour-rem(hStart,dXhour);
      if ~(rem(hStart,dXhour)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;
      timeflag=2;      
    elseif XlengthM>=(60.*7+1)&XlengthM<(60.*11+1),
      dXhour=2;
      sft=dXhour-rem(hStart,dXhour);
      if ~(rem(hStart,dXhour)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if m1==60,m1=0;h1=h1+1;end
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;
      timeflag=2;
    elseif XlengthM>=(60.*11+1)&XlengthM<(60.*24+1),
      dXhour=3;
      sft=dXhour-rem(hStart,dXhour);
      if ~(rem(hStart,dXhour)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;
      timeflag=2;
    elseif XlengthM>=(60.*24+1)&XlengthM<(60.*24.*2+1),
      dXhour=6;
      sft=dXhour-rem(hStart,dXhour);
      if ~(rem(hStart,dXhour)),sft=0;end
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;
      timeflag=2;
    elseif XlengthM>=(60.*24.*2+1)&XlengthM<(60.*24.*6+1),
      dXhour=12;
      sft=dXhour-rem(hStart,dXhour);  
      if ~(rem(hStart,dXhour)),sft=0;end
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;
      timeflag=3;
    elseif XlengthM>=(60.*24.*6+1)&XlengthM<(60.*24.*12+1),
      dXhour=24;
      sft=dXhour-rem(hStart,dXhour);  
      if ~(rem(hStart,dXhour)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;	
      timeflag=4;
    elseif XlengthM>=(60.*24.*6+1)&XlengthM<(60.*24.*15+1),
      dXhour=24.*2;
      sft=dXhour-rem(hStart,dXhour);  
      if ~(rem(hStart,dXhour)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if h1==24,h1=0;d1=d1+1;end
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;	
      timeflag=4;     
    elseif XlengthM>=(60.*24.*15+1)&XlengthM<(60.*24.*70+1);
      dXhour=24.*5;
      sft=dXhour-rem(hStart,dXhour);  
      if ~(rem(hStart,dXhour)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if h1==24,h1=0;d1=d1+1;end;      
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;	
      timeflag=4;
    elseif XlengthM>=(70.*24.*40+1)&XlengthM<(60.*24.*200);
      dXhour=24.*20;     
      sft=dXhour-rem(hStart,dXhour);  
      if ~(rem(hStart,dXhour)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if h1==24,h1=0;d1=d1+1;end;   
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;	
      timeflag=4;
    elseif XlengthM>=(60.*24.*200)&XlengthM<(60.*24.*366);
      dXhour=24.*30;
      sft=dXhour-rem(hStart,dXhour); 
      if ~(rem(hStart,dXhour)),sft=0;end;
      y1=yStart;
      d1=dStart;h1=hStart+sft;m1=0;s1=0;
      if h1==24,h1=0;d1=d1+1;end;   
      [y1,d1]=day_check(y1,d1);
      dX=dXhour.*60.*60;	
      timeflag=4;
      
    elseif (XlengthD>3)&(XlengthD<365.*2.5),
      
      dXday=ceil(XlengthD./6);
      sft=dXday-rem(dStart,dXday); 
      if ~(rem(dStart,dXday)),sft=0;end;
      y1=yStart;
      d1=dStart+sft;
      h1=0;m1=0;s1=0;
      [y1,d1]=day_check(y1,d1);
      dX=dXday.*24.*60.*60;
      timeflag=4;
    elseif (XlengthD>=365.*2.5)&(XlengthD<365.*10)
      dXyear=1;
      sft=dXyear-rem(yStart,dXyear);  
      if ~(rem(yStart,dXyear)),sft=0;end;
      y1=yStart+sft;d1=1;h1=0;m1=0;s1=0;
      dX=dXyear.*(365+isleap(y1)).*24.*60.*60;
      timeflag=5;
    elseif (XlengthD>=365.*10)&(XlengthD<365.*30)
      dXyear=3;
      sft=dXyear-rem(yStart,dXyear);  
      if ~(rem(yStart,dXyear)),sft=0;end;
      y1=yStart+sft;d1=1;h1=0;m1=0;s1=0;
      dX=dXyear.*(365+isleap(y1)).*24.*60.*60;
      timeflag=5;
    elseif (XlengthD>=365.*30)&(XlengthD<365.*100)
      dXyear=10;
      sft=dXyear-rem(yStart,dXyear);  
      if ~(rem(yStart,dXyear)),sft=0;end;
      y1=yStart+sft;d1=1;h1=0;m1=0;s1=0;
      dX=dXyear.*(365+isleap(y1)).*24.*60.*60;
      timeflag=5;
    elseif (XlengthD>=365.*100)&(XlengthD<365.*300)
      dXyear=20;
      sft=dXyear-rem(yStart,dXyear);  
      if ~(rem(yStart,dXyear)),sft=0;end;
      y1=yStart+sft;d1=1;h1=0;m1=0;s1=0;
      dX=dXyear.*(365+isleap(y1)).*24.*60.*60;
      timeflag=5;
    elseif (XlengthD>=365.*300)&(XlengthD<365.*1000)
      dXyear=50;
      sft=dXyear-rem(yStart,dXyear);  
      if ~(rem(yStart,dXyear)),sft=0;end;
      y1=yStart+sft;d1=1;h1=0;m1=0;s1=0;
      dX=dXyear.*(365+isleap(y1)).*24.*60.*60;
      timeflag=5;
    end
    
    if time_type=='dep',        
      X=DSdate2time(y1,d1,h1,m1,round(s1));
    elseif time_type=='mat',
      % dX in decimal days
      X=DSdate2mat(y1,d1,h1,m1,round(s1));
      dX=dX./86400;
    end
    
  end
  
  % Check for boundaries based on location of first tick mark and end of axis
  if y1~=yStop
    YearBoundary=1;
  else
    YearBoundary=0;
  end
  
  if d1~=dStop
    DayBoundary=1;
  else
    DayBoundary=0;
  end
  
  
  
  % Define tick marks - add mutiples of dX to improve accuracy
  
  NTick=1;
  NTickApprox=Xlength./dX; 
  
  while X<=Xlim(2);
    
    XTick(NTick)=X;
    
    % Change calculation according to time_type.
    
    
    if time_type=='dep',
      [date]=DStime2date(XTick(NTick));
      y=date(:,1);d=date(:,2);h=date(:,3);m=date(:,4);s=date(:,5);
    elseif time_type=='mat',
      date=DSmat2date(XTick(NTick));
      y=date(:,1);d=date(:,2);h=date(:,3);m=date(:,4);s=date(:,5);
    end
    
    s=round(s);
    if s==60, s=0;m=m+1;end;
    if m==60, m=0;h=h+1;end;
    if h==24, h=0;d=d+1;end;
    
    % Check for leap years which need correcting
    % Check 1 - if dXyear is used then adjust dX according to whether the
    % next year is a leap year or not
    % Check 2 - for dX = number of days, check that days do not overrun the
    % end of a year
    
    % Correction for leap years depends on time_type
    switch time_type
    case 'dep'
      if exist('dXyear')       
        dX=(365.*dXyear+sum(isleap(y:y+dXyear))).*24.*60.*60;
      elseif exist('dXday')       
        [y2,d]=day_check(y,d);
        if y2>y,
          XTick(NTick)=X+1.*24.*60.*60;
        end
      end
    case 'mat'
      if exist('dXyear')       
        %dX=(365+isleap(y));
        dX=(365.*dXyear+sum(isleap(y:y+dXyear)));
        
      elseif exist('dXday')       
        [y2,d]=day_check(y,d);
        if y2>y,
          XTick(NTick)=X+1;
        end
      end
    end
    
    
    % Generate timestr here
    
    Str=DSdate2str(y,d,h,m,s);
    YStr=Str(1:4);
    DStr=Str(6:8);
    DHMStr=Str(6:14);
    DHStr=Str(6:11);HMStr=Str(10:14);HMSStr=Str(10:17);MSStr=Str(13:17);
     
    if timeflag==0,
      XTickLabels(NTick,1:5)=MSStr;
      timestr='min sec (UT)';
    elseif timeflag==1
      XTickLabels(NTick,1:8)=HMSStr;
      timestr='hour min sec (UT)';
    elseif timeflag==2,
      if DayBoundary
        XTickLabels(NTick,1:9)=DHMStr;
        timestr='DOY hour min (UT)';
      else        
        XTickLabels(NTick,1:5)=HMStr;
        timestr='hour min (UT)';
      end
    elseif timeflag==3,
      XTickLabels(NTick,1:6)=DHStr;
      timestr='Day of Year hour (UT)';
    elseif timeflag==4
      if YearBoundary
        XTickLabels(NTick,1:6)=[YStr(3:4),' ',DStr];
        timestr='Year DOY (UT)';
      else
        XTickLabels(NTick,1:3)=DStr;
        timestr='Day of Year (UT)';
      end
    elseif timeflag==5&exist('dXyear')
      XTickLabels(NTick,1:4)=num2str(y);
      timestr='Year';
    end
    
    X=X+dX;   
    NTick=NTick+1;      
    
  end
  
  NTick=NTick-1;
  
  set(handle(n),'XTickMode','manual');
  set(handle(n),'XTick',XTick);
  set(handle(n),'XTickLabelMode','manual');
  set(handle(n),'XTickLabel',XTickLabels);
  
  % EAL 23-09-2002 Calculate datestring for x axis label from current axis start time
  % EAL 27-03-2003 Modify to include month and day
  [LabelYear,LabelMonth,LabelDay]=doy2ymd(y1,d1);
  MonthString={'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
  datestring=sprintf('%4d %s %02d (%03d) ',y1,MonthString{LabelMonth},LabelDay,d1);
  
  %datestring=sprintf('%4d Day %d, ',y1,d1);
   
  if timeflag==0
    datestring=([datestring,'hour ',num2str(h1),', ']);
  elseif timeflag==2&DayBoundary
    datestring=([datestring(1:4),', ']);
  elseif timeflag==2&(~DayBoundary)
    datestring=([datestring(1:18),' ']);
  elseif timeflag==3
    datestring=([datestring(1:4),', ']);
  elseif timeflag==4&YearBoundary
    datestring='';
  elseif timeflag==4&(~YearBoundary)
    datestring=([datestring(1:4),', ']);
  elseif timeflag==5
    datestring='';
  end
  
  if n==nplot&keep_xlabels,
    
    xt=get(gca,'XTick');
    
      XLabelHandle=get(handle(n),'XLabel');
      set(XLabelHandle,'String',[datestring,timestr]);
  end
  
end

for n=1:nplot,
  set(handle(n),'XTick',XTick);
  set(handle(n),'TickDir','out');
  set(handle(n),'TickLength',[0.008 0.003]);
  if n~=nplot&~selhandle,set(handle(n),'XTickLabel',[]);end;
end

if nargout
    ReturnHandle=handle;
end

% End of main routine


% Local functions to make TimeAxisSet self contained 
% Function DAY_CHECK---------------------------------------------------------------
function [y1,d1]=day_check(y1,d1);

% [y,d]=day_check(y,d);
% Function to check whether a year boundary has been crossed
% V 0.0 28-07-1998 EAL Rounding bug fixed
% V 0.1 06-02-2001 EAL Bug fix in yy -> yyyy code
%                      Vectorised

% Check for 2 digit year

i=find(y1<49);
y1(i)=y1(i)+2000;
i=find(y1<100);
y1(i)=y1(i)+1900;
clear i;

rem1=rem(y1,4)==0;
rem2=rem(y1,100)==0;
rem3=rem(y1,400)==0;
diy=365+(xor(rem1,rem2)|rem3);

for i=1:length(y1),
  if d1(i)>=365,
    if floor(d1(i))>diy(i),y1(i)=y1(i)+1;d1(i)=d1(i)-diy(i);end
  end
end

% End function DAY_CHECK

% Function ISLEAP-------------------------------------------------------------
function ans=isleap(y);
% Function to return 0 if y is not a leap year, and 1 if it is.

rem1=rem(y,4)==0;
rem2=rem(y,100)==0;
rem3=rem(y,400)==0;

ans=0+(xor(rem1,rem2)|rem3);

% End function ISLEAP

% Function DSdate2str----------------------------------------------------------
function [str]=DSdate2str(varargin)
% DSdate2str Function to convert date [((yy)yy) doy h m s] to string
%
% DSstr = DSdate2str(DSdate)
% or
% DStime = DSdate2str([(yy)yy],doy,h,m,s);
%
% DSdate = [(yy)yy doy h m s] : 4 digit year (optional), day of year, hour, minute, second
% yy     = 2 or 4 digit year (optional)
% doy    = day of year
% h      = hour
% m      = min
% s      = second
% DSstr  = DServe date string
%
% V 0.0 EAL 01-02-2001 Converts 2 digit years to 4 digit years 
%                      Check for single date input in column format 
%                      Updated method

% Check number of input arguments
switch nargin
% Single array    
case 1
    [nrow,ncol]=size(varargin{1});
    switch ncol
    case 4
        d=varargin{1}(1);
        h=varargin{1}(2);
        m=varargin{1}(3);
        % Only consider integer seconds
        s=fix(varargin{1}(4));
    case 5
        y=varargin{1}(1);
        d=varargin{1}(2);
        h=varargin{1}(3);
        m=varargin{1}(4);
        s=varargin{1}(5);
    otherwise
        error('Incorrect number of arguments');
    end
case 4
    d=varargin{1};
    h=varargin{2};
    m=varargin{3};
    s=fix(varargin{4});
case 5
    y=varargin{1};
    d=varargin{2};
    h=varargin{3};
    m=varargin{4};
    s=fix(varargin{5});    
otherwise
    error('Incorrect number of arguments');
end

if exist('y','var')&~isempty(y)
    str=sprintf('%04d %03d %02d %02d %02d',y,d,h,m,s);
else
    str=sprintf('%03d %02d %02d %02d',d,h,m,s);
end

% End function DSdate2str

function [yy,mm,dd] = doy2ymd(yy,daynum);

%--------------------------------------------------------------------------
% DOY_YMD M function to convert year and day of year to year, month, day
% [yy,mm,dd] = doy2ymd(yy,daynum)
%
% V 0.0 EAL  Jun 18th 1997.
% V 0.1 EAL  Jan 26th 2001. Not yet vectorised
% V 0.2 EAL  Feb 06th 2001. Bug fix for days at end of months
% V 0.3 EAL  Feb 08th 2001. Name change for consistency with DServe functions

% Check for a four digit year

i=find(yy<49);
yy(i)=yy(i)+2000;
i=find(yy<100);
yy(i)=yy(i)+1900;
clear i;

dom(1:12,1) = [31 28 31 30 31 30 31 31 30 31 30 31]';
dom(1:12,2) = [31 29 31 30 31 30 31 31 30 31 30 31]';

sdom=cumsum(dom);

rem1 = rem(yy,4)==0;
rem2 = rem(yy,100)==0;
rem3 = rem(yy,400)==0;
leap = (xor (rem1,rem2)|rem3);

mm=zeros(size(yy));
dd=zeros(size(yy));

for i=1:length(yy),
  mm(i) = min(find(daynum(i)<=sdom(:,leap(i)+1)));
  if mm(i)>1,
    dd(i)=daynum(i)-sdom(mm(i)-1,leap(i)+1);
  elseif mm(i)==1
    dd(i)=daynum(i); 
  end
end

% End function doy2ymd

function mtime = DSdate2mat(DSdate,varargin)
% DSdate2mat Function to convert DServe date [yyyy doy h m s] to matlab time
%
% mtime = DSdate2mat(DSdate)
% or
% mtime = DSdate2mat((yy)yy,doy,h,m,s);
%
% DSdate = DServe date format [yyyy doy h m s]
% 
% yy     = 2 or 4 digit year
% doy    = day of year
% h      = hour
% m      = min
% s      = second
%
% mtime  = matlab time format 
%
% V 0.0 EAL 02-02-2001
% V 0.1 EAL 05-02-2001 Takes comma separated argument list
% V 0.2 EAL 06-02-2001 Checks for daynumbers past end of year
%                      Check for single date input in column format
% V 0.3 EAL 08-02-2001 Update some function names (datecheck, ymd2doy doy2ymd)

[nrow,ncol]=size(DSdate);

% Check for single date input in column format

if nrow==5&ncol==1,
   DSdate=DSdate';
end	

% Check number of input arguments

if length(varargin)==4,
  if ncol>nrow,DSdate=DSdate';end
  for i=1:4,
    [nrow,ncol]=size(varargin{i});
    if ncol>nrow,varargin{i}=varargin{i}(1,:)';end
  end
  DSdate=[DSdate,varargin{1},varargin{2},varargin{3},varargin{4}];
elseif length(varargin),
  disp('Incorrect number of input parameters')
  disp('Useage: mat = DSdate2mat([(yy)yy doy h m s])')
  disp('        mat = DSdate2mat((yy)yy, doy, h, m, s)')
  mtime = NaN;
  return;
end

% Check for a four digit year

i=find(DSdate(:,1)<49);
DSdate(i,1)=DSdate(i,1)+2000;
i=find(DSdate(:,1)<100);
DSdate(i,1)=DSdate(i,1)+1900;
clear i;

% Check for days past end of year

[DSdate(:,1),DSdate(:,2)]=daycheck(DSdate(:,1),DSdate(:,2));

% Convert doy to day month 

[yyyy,mm,dd]=doy2ymd(DSdate(:,1),DSdate(:,2));

mtime=datenum(yyyy,mm,dd,DSdate(:,3),DSdate(:,4),DSdate(:,5));

% End of function DSdate2mat

function [y1,d1]=daycheck(y1,d1);

% [y,d]=daycheck(y,d);
% Function to check whether a year boundary has been crossed
% V 0.0 28-07-1998 EAL Rounding bug fixed
% V 0.1 06-02-2001 EAL Bug fix in yy -> yyyy code
%                      Vectorised
% V 0.2 08-02-2001 EAL Name change for consistency with DServe functions

% Check for 2 digit year

i=find(y1<49);
y1(i)=y1(i)+2000;
i=find(y1<100);
y1(i)=y1(i)+1900;
clear i;

rem1=rem(y1,4)==0;
rem2=rem(y1,100)==0;
rem3=rem(y1,400)==0;
diy=365+(xor(rem1,rem2)|rem3);

for i=1:length(y1),
  if d1(i)>=365,
    if floor(d1(i))>diy(i),y1(i)=y1(i)+1;d1(i)=d1(i)-diy(i);end
  end
end

% End of function day check


function DSdate = DSmat2date(mtime)
% DSmat2date Function to convert matlab time to DServe date [yyyy doy h m s]
%
% mtime   = matlab time format 
% DSdate  = DServe date format [yyyy doy h m s]
%
% V 0.0 EAL 02-02-2001
% V 0.1 EAL 08-02-2001 Update some function names (datecheck, ymd2doy doy2ymd)
%

[nrow,ncol]=size(mtime);
if ncol>nrow, mtime=mtime';end

[yyyy,mm,dd,h,m,s]=datevec(mtime);

% Convert dd mm to day of year

doy=ymd2doy(yyyy,mm,dd);

DSdate=[yyyy,doy,h,m,s];

% End of function DSmat2date

function [daynum] = ymd2doy(yy,mm,dd);

% [daynum] = ymd2doy(yy,mm,dd);
%
% M function to convert year,month and day of month to day of year
% V 0.0 EAL April 9th 1997.
% V 0.1 EAL Feb 2nd 2001. Takes array input, returns column output
% V 0.2 EAL Feb 5th 2001. Vectorised
% V 0.3 EAL Feb 08th 2001. Name change for consistency with DServe functions

i=find(yy<50);
  yy(i)=yy(i)+2000;
i=find(yy<100);
  yy(i)=yy(i)+1900;
clear i;

% Swap row to column format

[nrow,ncol]=size(yy);
if ncol>nrow,yy=yy';end

[nrow,ncol]=size(mm);
if ncol>nrow,mm=mm';end

[nrow,ncol]=size(dd);
if ncol>nrow,dd=dd';end

dom(1:12,1) = [31 28 31 30 31 30 31 31 30 31 30 31]';
dom(13:24,1) = [31 29 31 30 31 30 31 31 30 31 30 31]';

sdom(1:12,1)=cumsum(dom(1:12));
sdom(13:24,1)=cumsum(dom(13:24));

rem1 = rem(yy,4)==0;
rem2 = rem(yy,100)==0;
rem3 = rem(yy,400)==0;
leap = (xor (rem1,rem2)|rem3);

daynum=sdom(mm+(leap.*12))-dom(mm+(leap.*12))+dd;

% End of function ymd2doy