function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 06-Aug-2014 14:24:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function r=get_translate(tagname)
r=str2double(get(findobj('tag',tagname),'String'));
if isnan(r)
    warning('BAD');
end


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
persistent axes
me = 9.1093897E-31;
eV = 1.60217733E-19;
e0 = 8.854187817e-12;
% Material Constants
f   = 0.25;             % Geometry
% Get variables
e_r = get_translate('ed_e_r');            % Dielectric constant
m_e = get_translate('ed_m_electron');
m_h = get_translate('ed_m_hole');
gamma_e = 1e15/get_translate('ed_elec_scatt');
gamma_h = 1e15/get_translate('ed_hole_scatt');
N_dope  = 1e6*get_translate('ed_N_doping');
P_dope  = 1e6*get_translate('ed_P_doping');
N_ex    = 1e6*get_translate('ed_N_excite');
t  = linspace(get_translate('ed_thz_min'),get_translate('ed_thz_max'));
w  = t*2*pi*1e12;

% Functions
w_0   = @(N,m_eff)(sqrt((f*N*eV^2)/(m_eff*me*e_r*e0)));
condSP  = @(N,m_eff,gamma, w)((1i*(N)*eV^2*w)./(m_eff*(w.^2-w_0(N,m_eff).^2+1i*w*gamma)));
condD   = @(N,m_eff,gamma,w) ((1i*(N)*eV^2*w)./(m_eff*(w.^2+1i*w*gamma)));
% Setup
approach = get(findobj('tag','ed_approach'),'Value');
if approach == 1
    % Drude
    cond = condD;
elseif approach == 2
    % Surface plasmon
    cond = condSP;
end
c_before_e = cond(N_dope, m_e,gamma_e,w);
c_before_h = cond(P_dope, m_h,gamma_h,w);   
c_before   = c_before_e+c_before_h;
c_after_e = cond(N_dope+N_ex, m_e,gamma_e,w);
c_after_h = cond(P_dope+N_ex, m_h,gamma_h,w);
c_after   = c_after_e+c_after_h;
c_diff_e  = c_after_e - c_before_e;
c_diff_h  = c_after_h - c_before_h;
c_diff    = c_after-c_before;
% Plot
if isempty( axes )
    axes.before=findobj('tag','axes_before');
    axes.after=findobj('tag','axes_after');
    axes.diff=findobj('tag','axes_differential');
end
plot(axes.before,...
    t,real(c_before_e),'b:',t,imag(c_before_e),'r:',...
    t,real(c_before_h),'b--',t,imag(c_before_h),'r--',...
    t,real(c_before),'b-',t,imag(c_before),'r-');
plot(axes.after,...
    t,real(c_after_e),'b:',t,imag(c_after_e),'r:',...
    t,real(c_after_h),'b--',t,imag(c_after_h),'r--',...
    t,real(c_after),'b-',t,imag(c_after),'r-');

plot(axes.diff,...
    t,real(c_diff_e),'b:',t,imag(c_diff_e),'r:',...
    t,real(c_diff_h),'b--',t,imag(c_diff_h),'r--',...
    t,real(c_diff),'b-',t,imag(c_diff),'r-');
% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

% Update handles structure
guidata(handles.figure1, handles);



function ed_m_electron_Callback(hObject, eventdata, handles)
% hObject    handle to ed_m_electron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_m_electron as text
%        str2double(get(hObject,'String')) returns contents of ed_m_electron as a double


% --- Executes during object creation, after setting all properties.
function ed_m_electron_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_m_electron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_m_hole_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to ed_m_hole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_m_hole as text
%        str2double(get(hObject,'String')) returns contents of ed_m_hole as a double


% --- Executes during object creation, after setting all properties.
function ed_m_hole_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_m_hole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_elec_scatt_Callback(hObject, eventdata, handles)
% hObject    handle to ed_elec_scatt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_elec_scatt as text
%        str2double(get(hObject,'String')) returns contents of ed_elec_scatt as a double


% --- Executes during object creation, after setting all properties.
function ed_elec_scatt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_elec_scatt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_hole_scatt_Callback(hObject, eventdata, handles)
% hObject    handle to ed_hole_scatt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_hole_scatt as text
%        str2double(get(hObject,'String')) returns contents of ed_hole_scatt as a double


% --- Executes during object creation, after setting all properties.
function ed_hole_scatt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_hole_scatt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_N_doping_Callback(hObject, eventdata, handles)
% hObject    handle to ed_N_doping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_N_doping as text
%        str2double(get(hObject,'String')) returns contents of ed_N_doping as a double


% --- Executes during object creation, after setting all properties.
function ed_N_doping_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_N_doping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_P_doping_Callback(hObject, eventdata, handles)
% hObject    handle to ed_P_doping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_P_doping as text
%        str2double(get(hObject,'String')) returns contents of ed_P_doping as a double


% --- Executes during object creation, after setting all properties.
function ed_P_doping_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_P_doping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_N_excite_Callback(hObject, eventdata, handles)
% hObject    handle to ed_N_excite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_N_excite as text
%        str2double(get(hObject,'String')) returns contents of ed_N_excite as a double


% --- Executes during object creation, after setting all properties.
function ed_N_excite_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_N_excite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_thz_min_Callback(hObject, eventdata, handles)
% hObject    handle to ed_thz_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_thz_min as text
%        str2double(get(hObject,'String')) returns contents of ed_thz_min as a double


% --- Executes during object creation, after setting all properties.
function ed_thz_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_thz_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_thz_max_Callback(hObject, eventdata, handles)
% hObject    handle to ed_thz_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_thz_max as text
%        str2double(get(hObject,'String')) returns contents of ed_thz_max as a double


% --- Executes during object creation, after setting all properties.
function ed_thz_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_thz_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ed_approach.
function ed_approach_Callback(hObject, eventdata, handles)
% hObject    handle to ed_approach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ed_approach contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ed_approach


% --- Executes during object creation, after setting all properties.
function ed_approach_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_approach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_e_r_Callback(hObject, eventdata, handles)
% hObject    handle to ed_e_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_e_r as text
%        str2double(get(hObject,'String')) returns contents of ed_e_r as a double


% --- Executes during object creation, after setting all properties.
function ed_e_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_e_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
