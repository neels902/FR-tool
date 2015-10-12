function [H, Chirala]= DefineChiral(rcdBmax, reply)

% define the chirality of the MC


L= length(rcdBmax);
interval= floor(L/20);
intialdata= sum(rcdBmax(interval: (3*interval)) )            /   (2*interval);
finaldata=  sum(rcdBmax((L- (3*interval)):(L-interval))  )   /   (2*interval);

whichlarge= finaldata - intialdata ;

if whichlarge >0
    H=1;  % defines RH flux rope in RTN coordinates
else
    H=-1;
end

if reply> 0.5 % ie in VSO
    Chiral=-1* H;
else
    Chiral=H;
end


% rtn definition therefore needed early if stat for vso
if Chiral==1
    Chirala='Right Handed';
elseif Chiral==-1
    Chirala='Left Handed';
else
    error('helicity not -1 or +1');
end

return