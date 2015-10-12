function [hp]=subpanel(ny,nx,n);
% [hpanel]=subpanel(nx,ny,n);
%
% EAL Function to produce closed up panels
% 
% V 0.0 10/1998
% V 0.1 04/11/1998: Sets x axis labels to [] unless it is a bottom subpanel
% V 0.2 05/11/1998: Always sets bottom panel to have axis on right
% V 0.3 29/06/2001: Set vertical alignment of y axis labels according to y axis
%                   location
% V 0.4 28/06/2002: Only return handle if an output argument has been supplied

if nargin==1,
  tempstr=num2str(ny);
  ny=str2num(tempstr(1));
  nx=str2num(tempstr(2));
  n=str2num(tempstr(3));
end

hpanel=subplot('Position',[0.15, 0.1+(ny-n)*(0.8./ny),0.75,0.8./ny]);
set(hpanel,'Box','on');


if ((rem(n,2)>0)&(rem(ny,2)==0))|((rem(n+1,2)>0)&(rem(ny+1,2)==0)),
  set(hpanel,'YAxisLocation','right');
  h=get(gca,'YLabel');
  set(h,'VerticalAlignment','top');
else
  h=get(gca,'YLabel');
  set(h,'VerticalAlignment','bottom'); 
end
hold on;

if n~=ny,
  set(hpanel,'XTickLabel',[]);
end

% Only define handle variable for new subpanel if an output argument has been supplied
if nargout
  hp=hpanel;
end