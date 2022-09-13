% clear all

me = 9.10938215E-31;
q = 1.60217646E-19;
permittivity = 8.854187817620E-12;
meff = 0.47*me;
f = (0:0.1:10); % create frequency range: 0 - 10 THz
f = f';
w = f*1e12*2*pi;
A = 1; % Dummy factor in Lorentzian Equation
epsilon = 12.95;
Np = 1e23; Neq = 1e14; gamma = 0.5e14; % Change these values for shape of graph

%% Choose Method
method = 1; % SP/Lorentzian Model
% method = 2; % Drude Model
% method = 3; % Drude-Smith Model

%% Lorentzian
if method == 1
    plasma_freq = @(w,f,N,meff)(ones(size(w)).*sqrt(0.5*N*q^2/(meff*epsilon*permittivity)));
    w0  = plasma_freq(w,f,Np+Neq,meff);
    w0eq = plasma_freq(w,f,Neq,meff);
    lor = @(w,w0,N,gamma,meff)((1i*N*q^2*w)./(meff*(w.^2-w0.^2+1i*w*gamma)));
    conductivity_fit = A*(lor(w,w0,Np+Neq,gamma,meff)- lor(w,w0eq,Neq,gamma,meff));
end
%% Drude Model
if method == 2
    drude = ((1i*(2e23)*q^2*w)./(mh_eff*(w.^2+1i*w*1e13)));
end
%% Drude-Smith Model
if method == 3
    c = -1;
    drudeSmith = ((1i*(1e20)*q^2*w)./(meff*(w.^2+1i*w*1e13))) + c*((1i*(1e20)*q^2*w)./(meff*(w.^2+1i*w*1e13)))./(1 - 1i*w*1e-13);
end
%% Plots
% figure
% box on
% C = linspecer('insert number of graphs here');
% for j=1:5
% plot(f,real(a(:,j)),f,imag(a(:,j)),'color',C(j,:),'linewidth',1.5)
% hold on
% end
% y(:,2) = conductivity_fit;

figure
box on
plot(f,real(conductivity_fit),f,imag(conductivity_fit))