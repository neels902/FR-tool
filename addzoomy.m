function h=addzoomy(f)

% An exact copy of Tim's addzm, except that it launches zoomy, my copy of
% Elizabeth's zm, with the text output supressed, so don't get words all
% over shop if you use it in the middle of a script/ function. Intended for
% experienced zm-ers only! EMH 28/05/08

% addzm  Add a button to a figure to launch zooming tool zm
%
% h=addzm(f)
%
% Adds a button to the menu bar of figure f, which when pressed invokes 
% the zooming tool zm
%
% h holds the handle of the new uimenu object
%
% If f is omitted, the current figure (as returned by gcf) is used
%
% Needs zm and daughter functions
%
% Tim Horbury, December 2002

% Revision history:
% 06.12.02: first version. Needs a change to TimeAxisSet to work properly
% 08.12.02: bugfix in grabbing handle of current figure. EAL's change to TimeAxisSet
%           works fine. Only add button is there isn't one there already

if nargin<1
 f=gcf;
end

% Only add a zoom button if there isn't one there already
if ~haszoom(f)
 hand=uimenu(f,'Label','Zoom','Callback','zoomy');
end

if nargout==1
 h=hand;
end

% Main program ends

% ---------------------------------------------------------------------------
% Test whether the figure already has a zoom button
function z=haszoom(f)

z=0;

% Look through all the figure's children, and see if any of them are a uimenu
% If they are, we can only be sure that they're a addzm button if they are
% labelled 'Zoom' and call zm when they're pressed
c=get(f,'Children');
if ~isempty(c)
 for i=1:length(c)
  if strcmp(get(c(i),'Type'),'uimenu')
   if strcmp(get(c(i),'Label'),'Zoom')&strcmp(get(c(i),'Callback'),'zoomy')
    z=1;
   end
  end
 end
end

% Program ends