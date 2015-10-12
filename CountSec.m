function ans= CountSec(time)

%
% In an input of a time interval in datenum or datevec [6col] format, 
% routine will output the number of seconds in the the interval. Vetrical
% array of times also works.
% I: time
% O: # of sec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Space and Atmospheric Physics Group
% The Blackett Laboratory - Imperial College London
% Neel Savani 12/03/08



[m,n]= size (time);

if n==1
ans= time* 86400;
elseif n==6
    time= datenum(time);
    ans= time* 86400;
else 
    output('fucking idiot input a format of datevec or datenum.');
end


return





