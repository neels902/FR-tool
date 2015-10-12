function Result= NewReadAce(fileToRead1)
%returns data ready for ReadstereoVel routine and full subpanel plots.




DELIMITER = ' ';
HEADERLINES = 44;

% Import the file
newData1 = importdata(fileToRead1, DELIMITER, HEADERLINES);

% Create new variables in the caller workspace from those fields.
% vars = fieldnames(newData1);
textdata=newData1.textdata;
data=newData1.data;
%y/DOY/h/min/sec   Bx/By/Bz/Bmag 


[r,c]= size(data);
%CLEAN DATA OF ERRONEOUS RESULTS

for m=6:1:c-1
    j=find(data(:,m)<-300);
    data(j,m)=nan;
end
    jj=find(data(:,9)>300);
    data(jj,9)=nan;

% convert DOY to DOM 
D1t1= data;
b=data(:,6:end);
[dom,month]=doy2dom(D1t1(:,2),D1t1(:,1));
D1t2=[D1t1(:,1),month,dom,D1t1(:,3:5)];

bt=datenum(D1t2);
L=-1*ones(length(bt),1);

%1.datenum, 2.B_X,3.B_Y,4. B_Z,    5.V_X,6.V_Y,7.V_Z,   8.N_P,  9.T,
%10.Beta  11. R(AU), 12. H Lat, 13. H Long, 14. N_alpha/N_P, 15. |B|,
Result=[bt,b(:,1),b(:,2),b(:,3)]; % no Bmag used

return









