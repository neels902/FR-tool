function  [E_min, E_int, E_max]=Project2Vardirn (data, emin, eint, emax)

%DEFINE ORIGINAL FIELD DIRECTION
%[E_x, E_y, E_z]=Project2Vardirn (data, emin, eint, emax)
%x= data(:,1); y= data(:,2); z= data(:,3);
%data must be 3col's
%matrix= [emin emax eint];


%NOTE EINT IS IN Y DIRN
matrix= [emin eint emax];
Bnew= data* matrix;

%NOTE EINT IS IN Y DIRN
E_min= Bnew(:,1);
E_int= Bnew(:,2);
E_max= Bnew(:,3);


return
