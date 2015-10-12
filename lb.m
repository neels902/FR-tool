function varargout = lb(varargin)
% LB Application M-file for lb.fig
%   LB, by itself, creates a new LB or raises the existing
%   singleton*.
%
%   H = LB returns the handle to a new LB or the handle to
%   the existing singleton*.
%
%   LB('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in LB.M with the given input arguments.
%
%   LB('Property','Value',...) creates a new LB or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before lb_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to lb_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lb

% Copyright 2000-2006 The MathWorks, Inc.

% Last Modified by GUIDE v2.5 15-Aug-2011 11:18:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @lb_OpeningFcn, ...
                   'gui_OutputFcn',     @lb_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before lb is made visible.
function lb_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lb (see VARARGIN)

% create temp structure function which will house all the FR fit data
FR.B0= 1;
FR.Y0= 1;
FR.Coord= 'RTN';
FR.colour = 1;
FR.H= 'Right handed';
FR.MVA=1;  % defined as RH coord system, with int vector for +ve axial field, min vector for +ve x st towards(away) the sun for VSO (RTN)
FR.flipx= 1;
FR.flipz= 1;
FR.fval= 0;
FR.check= 0;
FR.check_chi_sqd= 0;

FR.MODEL.rmBx=1;
FR.MODEL.rmBy=1;
FR.MODEL.rmBz=1;
FR.MODEL.rmBmag=1;
FR.MODEL.mtheta=1;
FR.MODEL.mphi=1;
FR.MODEL.mtime=1;

handles.FR=FR;
handles.current_data = [1,5,5,5];
handles.hand_Stack =999.999;

% Choose default command line output for lb
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Populate the listbox
update_listbox(handles)
set(handles.listbox1,'Value',[])

% UIWAIT makes lb wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lb_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.FR;


function update_button_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to update_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_listbox(handles)

function update_listbox(handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% Updates the listbox to match the current workspace
vars = evalin('base','who');
set(handles.listbox1,'String',vars)

function [var1,var2] = get_var_names(handles)
% Returns the names of the two variables to plot
list_entries = get(handles.listbox1,'String');
index_selected = get(handles.listbox1,'Value');
if length(index_selected) ~= 2
    errordlg('You must select two variables','Incorrect Selection','modal')
else
    var1 = list_entries{index_selected(1)};
    var2 = list_entries{index_selected(2)};
end 

function plot_button_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x,y] = get_var_names(handles);
handles.hand_Stack =figure;
app=evalin('base',x,';');
app2=evalin('base',y,';');
[r,c]=size(app);
if c ==1
    time=app;
    Bfield=app2;
else
    if c == 3
        time=app2;
        Bfield=app;
    else
        error ('incorrect inputs. 1 colm for time and 3 for Bfield required')
    end
end

GuiStack(time, Bfield, handles.hand_Stack);
handles.current_data = [time,Bfield];
guidata(hObject, handles);
temp=1;
% try
%     evalin('base',['plot(',x,',',y,')'])
%     
%     
% catch ex
%     errordlg(...
%       ex.getReport('basic'),'Error generating linear plot','modal')
% end

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = ispc;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on button press in pb_FR.
function pb_FR_Callback(hObject, eventdata, handles)
% hObject    handle to pb_FR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


temphand=get(0,'children');
if handles.hand_Stack==999.999
    disp('please press plot button first')
    tempstrg='FIRST you must: \n - highlight 2 variables from the list box \n - then hit the plot button. Doh!!';
    warndlg(sprintf(tempstrg),'!!! FOOLISH BOY !!!')
elseif isempty(temphand)
    disp('please press plot button first')
    tempstrg='YOU DELETED THE FIGURE, now you must: \n - highlight 2 variables from the list box \n - then hit the plot button. Doh!!';
    warndlg(sprintf(tempstrg),'!!! FOOLISH BOY !!!')
else
    Bfield=handles.current_data;
    Time=datevec(Bfield(:,1));
    BMAG= sqrt( (Bfield(:,2)).^2 + (Bfield(:,3)).^2 + (Bfield(:,4)).^2   );
    BBB=[Time,Bfield(:,2:4),BMAG];
    handles.FR=PlotRope (BBB,handles.FR.Coord,handles.FR.colour);

    % display the results
    Gui_display_results
    cDpP='The output results are defined as:';
    cDpB = 'B0= the magnetic field magnitude along the axis of the FR';
    cDpY = 'Y0= the estimated trajectory of the spacecraft through the FR as a fraction of the radius,';
    cDpY2 = '+ve# implies ABOVE the axis;    -ve# implies BELOW the axis';
    cDpC = 'Chirality= the sense of twist to be either Left or Right handed ';
    cDpR = 'RMS = is a quantifible measure of the uncertainty/goodness of the fit as defined by ';
    cDpR2= '<a href = "http://dx.doi.org/10.1029/2002JA009591">Lynch B.J. et al,JGR 2003</a>';
    cDpR3= 'RMS <0.36 is defined as a good fit; 0.36<RMS<0.45 is moderate; RMS<0.45 is bad';
    fprintf('%s \n %s \n %s \n %s \n %s \n %s%s \n %s \r', cDpP, cDpB, cDpY, cDpY2, cDpC, cDpR, cDpR2, cDpR3)
    %sites = 'dx.doi.org/10.1029/2002JA009591';
    
    ta = 'MVA: this is used to estimate the AXIS of the modeled FR.';
    tb = 'No further optimistaion of the axis orientation is carried out to aid the speed of calculation';
    tc = 'The intermediate eigen vector is regarded as the modeled FR axis';
    td= 'each Eigen value ratios is a quantitative measure to the uniqueness of the vector orientation';
    te= 'ideally the ratios should both be above 10, but this is rarely the case, both bove 5 is suitable';
    tf= 'If one of the ratio is between 1-3, then there is uncertainty in the FR axis in the plane of the 2 vectors';
    tg= 'Written by <a href = "https://sites.google.com/site/neelsavani">N.P. Savani</a>.';
    fprintf('\n %s \n %s \n %s \n %s \n %s \n %s \n %s \n', ta, tb, tc, td, te, tf, tg)
    
    
    temp=1;
 end




% --- Executes on selection change in pu_rtn.
function pu_rtn_Callback(hObject, eventdata, handles)
% hObject    handle to pu_rtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pu_rtn contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pu_rtn
val = get(hObject,'Value');
str = get(hObject, 'String');
switch str{val};
case 'RTN' % User selects peaks
	handles.FR.Coord = 'RTN';
case 'VSO' % User selects membrane
	handles.FR.Coord = 'VSO' ;
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function pu_rtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pu_rtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pu_colour.
function pu_colour_Callback(hObject, eventdata, handles)
% hObject    handle to pu_colour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pu_colour contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pu_colour
val = get(hObject,'Value');
str = get(hObject, 'String');
switch str{val};
case 'Purple' % User selects peaks
	handles.FR.colour = 1;
case 'Green' % User selects membrane
	handles.FR.colour = 2;
case 'Orange' % User selects membrane
	handles.FR.colour = 3;
case 'Black' % User selects membrane
	handles.FR.colour = 4;
end

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function pu_colour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pu_colour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ed_B0_Callback(hObject, eventdata, handles)
% hObject    handle to ed_B0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_B0 as text
%        str2double(get(hObject,'String')) returns contents of ed_B0 as a double


% --- Executes during object creation, after setting all properties.
function ed_B0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_B0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_Y0_Callback(hObject, eventdata, handles)
% hObject    handle to ed_Y0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_Y0 as text
%        str2double(get(hObject,'String')) returns contents of ed_Y0 as a double


% --- Executes during object creation, after setting all properties.
function ed_Y0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_Y0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1



function ed_St_Callback(hObject, eventdata, handles)
% hObject    handle to ed_St (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_St as text
%        str2double(get(hObject,'String')) returns contents of ed_St as a double


% --- Executes during object creation, after setting all properties.
function ed_St_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_St (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_En_Callback(hObject, eventdata, handles)
% hObject    handle to ed_En (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_En as text
%        str2double(get(hObject,'String')) returns contents of ed_En as a double


% --- Executes during object creation, after setting all properties.
function ed_En_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_En (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axis1_Callback(hObject, eventdata, handles)
% hObject    handle to axis1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axis1 as text
%        str2double(get(hObject,'String')) returns contents of axis1 as a double


% --- Executes during object creation, after setting all properties.
function axis1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axis1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axis2_Callback(hObject, eventdata, handles)
% hObject    handle to axis2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axis2 as text
%        str2double(get(hObject,'String')) returns contents of axis2 as a double


% --- Executes during object creation, after setting all properties.
function axis2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axis2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axis3_Callback(hObject, eventdata, handles)
% hObject    handle to axis3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axis3 as text
%        str2double(get(hObject,'String')) returns contents of axis3 as a double


% --- Executes during object creation, after setting all properties.
function axis3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axis3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_Ch_Callback(hObject, eventdata, handles)
% hObject    handle to ed_Ch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_Ch as text
%        str2double(get(hObject,'String')) returns contents of ed_Ch as a double


% --- Executes during object creation, after setting all properties.
function ed_Ch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_Ch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_Rm_Callback(hObject, eventdata, handles)
% hObject    handle to ed_Rm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_Rm as text
%        str2double(get(hObject,'String')) returns contents of ed_Rm as a double


% --- Executes during object creation, after setting all properties.
function ed_Rm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_Rm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


