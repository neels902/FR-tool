function [TimeStamp] = syncTime(h,DoTime)
% input two variables / one var or none
% h is for predefining the figure handle for which you want to define the 
% time for vertical lines.
% DoTime is is the actual Time you want plotting is already defined
%
% temp=syncTime;
% temp=syncTime([],temp);



%% define if there are initial inputs to teh routine, otherwise must set the
% handle and time stamp.
if ~exist('h','var')|isempty(h)
  h=gcf;
end
figure(h)

if ~exist('DoTime','var')|isempty(DoTime)
  disp('Define the Time of interest by Clicking Once.');  
  [DoTime,tempy]=ginput(1);
end
XLimP=[DoTime,DoTime];



%% Find figure children which are axes but not colorbars
ha=get(gcf,'Children');
isaxis=zeros(1,length(ha));
for i=1:length(ha)
    if strcmp(get(ha(i),'Type'),'axes')&isempty(strmatch('colorbar',get(ha(i),'DeleteFcn')))&isempty(strmatch('Colorbar',get(ha(i),'Tag'))),
        isaxis(i)=1;
    end
end
ha=ha(find(isaxis==1));
handle=ha;
handle=flipud(handle);
nplot=size(handle,1);



%%
for ii=1:1:nplot 
    YLimN(ii,1:2)=get(handle(ii),'YLim');
    % set Y plotting range
    YLimP(1)=min(YLimN(ii,1));
    YLimP(2)=max(YLimN(ii,2));
    axes(handle(ii)), hold on;
    H_Line(ii) = plot(XLimP,YLimP, ':k');   
end




%% OUTPUT
TimeStamp=XLimP(1);

return