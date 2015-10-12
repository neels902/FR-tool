function [] = zoomy(h,DoTime);
%
% An exact copy of Elizabeth's zm, except that the text output is
% suppressed, so don't get stuff coming up if it's use it in the middle of 
% a function/script. Intended for experienced zm-ers only! EMH 28/05/08
%
% M file to zoom into multiple stacked panel plots with time on x axis
% Original xlim saved in figure UserData, so will interfere with other
% uses of UserData
%
% V 0.0 EAL 12-02-2002
% V 0.1 EAL 13-02-2002 Bug fix in ordering of conditions 
% V 0.2 EAL 25-02-2002 Sort selected X limits  
% V 0.3 EAL 21-05-2002 If a figure has had zm used on it before, check to see whether current data 
%                      differs from old limits
%                      Find subpanel children before checking x limits
% V 0.4 EAL 19-07-2002 Allow figure handle as input argument
% V 0.5 EAL 22-10-2002 If axis limits are obviously not time, then do not apply TimeAxisSet
% V 1.0 EAL 30-10-2002 Redefine method of storing xlim in UserData using a structure, so extra UserData can be added
% V 1.1 EAL 05-11-2002 Define struct array in UserData called zm. X limits in zm.xlim
% V 1.2 EAL 05-06-2003 Add extra condition for identification of colorbar
% V 1.3 EAL 24-07-2003 Correct calculation of x axis extent: examine all axes, not just the last one  
% V 1.4 EAL 22-09-2003 Perform check on existence of TimeAxisSet: if it doesn't exist then do not try to update time axis
% V 2.0 EAL 22-03-2006 Add left and right functionality
% ZM
% 
% Usage
% ZM     - zoom on current figure
% ZM(h)  - zoom on figure h
% ZM(h,DoTime) - zoom on figure h and force whether or not TimeAxisSet is used
%
% Click twice with Left button to zoom in
% Click with Right button to end
% Click twice with Left button outside axes on left to move left by period covered by plot
% Click twice with Left button outside axes on right to move right by period covered by plot
% Return to zoom out to original size

if ~exist('h','var')|isempty(h)
  h=gcf;
end
figure(h)

% Check for existence of TimeAxisSet
if ~exist('TimeAxisSet','file')
  DoTime=0;
end

% Find figure children which are axes but not colorbars
ha=get(gcf,'Children');
isaxis=zeros(1,length(ha));
for i=1:length(ha)
    if strcmp(get(ha(i),'Type'),'axes')&isempty(strmatch('colorbar',get(ha(i),'DeleteFcn')))&isempty(strmatch('Colorbar',get(ha(i),'Tag'))),
        isaxis(i)=1;
    end
end
ha=ha(find(isaxis==1));

% Examine all axis objects to find data limits
axislim=[Inf 0];
for ia=1:length(ha)
  hc=get(ha(ia),'Children');
  for i=1:length(hc)
    xdata=get(hc(i),'XData');
    if min(xdata)<axislim(1),axislim(1)=min(xdata);end
    if max(xdata)>axislim(2),axislim(2)=max(xdata);end
  end
end

% Find out if figure is zoomable
tag=get(h,'Tag');

% Set up data before zooming
if ~strcmp(tag,'zoomable'),
  
  xlim=get(gca,'XLim');
  Properties.zm.xlim=xlim;
  set(h,'UserData',Properties);
  set(h,'Tag','zoomable');
  
else
  % Extract UserData
  % Check whether UserData is a structure
  % If not, assume that UserData contains x axis limits
  % If it is a structure, extract the xlim field of the structure
  Properties=get(h,'UserData');
  if isstruct(Properties)
    xlim=Properties.zm.xlim;
  else
    xlim=Properties;
    % If UserData is not already a structure, then redefine
    Properties.zm.xlim=xlim;
    set(h,'UserData',Properties);
  end
  
  % Work out whether the limits have changed 
  xchange=0;
  if axislim(1)~=xlim(1),xlim(1)=axislim(1);xchange=1;end
  if axislim(2)~=xlim(2),xlim(2)=axislim(2);xchange=1;end
  
  if (xchange)
    Properties.zm.xlim=xlim;
    set(h,'UserData',Properties);
  end
  
  %clear xlim Properties 
  
end

% Determine whether axis limits are appropriate for time labelling
if ~exist('DoTime','var')|isempty(DoTime)
  if (axislim(1)<0) | (axislim(2)<5000)
    DoTime=0;
  else
    DoTime=1;
  end
end

flag=1;
%{
disp('Click with left button on two x locations to zoom')
disp('Click with left button twice to left of axes to move left')
disp('Click with left button twice to right of axes to move right')
disp('Click outside axes on both sides to scale up by factor 2')
disp('Click with right button to end')
disp('Press return to return to full scale')
%}
while (flag)
    [xnew,dummy,button]=ginput(2);
    clim=get(gca,'XLim');
    crange=abs(clim(2)-clim(1));
    % Sort x values so can choose in either order
    xnew=sort(xnew);
    if length(button)<2,
        Properties=get(h,'UserData');
        set(ha,'XLim',Properties.zm.xlim);
        if (DoTime), TimeAxisSet;end
    elseif max(button)==3,
        flag=0;
    else
        if (xnew(1)<clim(1))&(xnew(2)<clim(1))
            xnew=clim-0.9*crange;     
        elseif (xnew(1)>clim(2))&(xnew(2)>clim(2))
            xnew=clim+0.9*crange;
        elseif (xnew(1)<clim(1))&(xnew(2)>clim(2));
            xnew=[clim(1)-crange clim(2)+crange];
        end
        set(ha,'XLim',xnew);
        if (DoTime), TimeAxisSet;end
    end
end