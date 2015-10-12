function S= axes_create

ex=zeros(1,3);
ey=zeros(1,3);
ez=zeros(1,3);
deg=zeros(1,2);

for theta=0:5:360
    
    THETA= theta*pi/180;
   
    
    for phi=0:1:180
        
        PHI= phi*pi/180;
        
        %MATLAB routine defines form +ve x-axis, use adams sph2car for -ve
        %x-axis
        
        
        %Angle
        deg(end+1,1:2)= [theta phi];
        
        %X-axis
        [x1,y1,z1] = sph2cart(THETA,PHI,1);
        ex(end+1,1:3)= [x1 y1 z1];
        
        %Y-axis
        [x2,y2,z2] = sph2cart(THETA+(pi/2) ,PHI,1);
        ey(end+1,1:3)= [x1 y1 z1];
        
        %Z-axis
        [x3,y3,z3] = sph2cart(THETA ,PHI+(pi/2),1);
        ez(end+1,1:3)= [x1 y1 z1];
        
        
    end
end


deg(1,:)=[];
ex(1,:)=[];
ey(1,:)=[];
ez(1,:)=[];
%OUTPUT STRUCTURE

S.deg=deg;
S.ex=ex;
S.ey=ey;
S.ez=ez;


return
