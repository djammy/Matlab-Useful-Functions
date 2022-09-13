function [] = FDM()
    % In the Finite Dipole Model, the tip is described by a spheroid with
    % length 2L in order to take into account that the tip in the
    % experiment is an elongated structure.

    R = 36e-9; % radius of curvature of tip in m
    L = 300e-9; % effective length of the prolate spheroid in m
    g = 0.7*exp(0.06i); % a complex factor describing the total charge induced in the spheroid
    
    d_0 = linspace(0,100,100); % minimum separation distance between the tip and the sample during the probe oscillation
    d_0 = d_0*1e-9; % minimum separation distance between the tip and the sample during the probe oscillation
    z_0 = 100e-9; % oscillation/vibration amplitude of the probe
    f_0 = 230e3;  % oscillation frequency of the probe
    T = 1.0/f_0; % period of oscillation of the probe
    w = linspace(890,1000,1000); % in cm^-1

    epsilon_0 = 1; % dielectric function of air
    epsilon_tip = -1000+500i; % dielectric function of tip
    epsilon_sample = 9.997e-1 + 1i*6.6352e5; % dielectric function of sample
    
    % Dielectric function of sample
    epsilon_inf_parallel = 6.78; % no units
    w_LO_parallel = 967; % in cm^-1
    w_TO_parallel = 782; % in cm^-1
        
    epsilon_inf_perpendicular = 6.56; % no units
    w_LO_perpendicular = 971; % in cm^-1
    w_TO_perpendicular = 797; % in cm^-1
    
    parameter_damping = 6.6; % in cm^-1

    for j = 1:length(w)
        epsilon_parallel(j) = epsilon_inf_parallel + ((epsilon_inf_parallel*(w_LO_parallel^2 - w_TO_parallel^2))/(w_TO_parallel^2 - w(j)^2 - 1i*parameter_damping*w(j)));
        epsilon_perpendicular(j) = epsilon_inf_perpendicular + ((epsilon_inf_perpendicular*(w_LO_perpendicular^2 - w_TO_perpendicular^2))/(w_TO_perpendicular^2 - w(j)^2 - 1i*parameter_damping*w(j)));
        beta_parallel(j) = (sqrt(epsilon_parallel(j)*epsilon_perpendicular(j)) - 1)/(sqrt(epsilon_parallel(j)*epsilon_perpendicular(j)) + 1);
        beta_perpendicular(j) = (epsilon_perpendicular(j) - 1)/(epsilon_perpendicular(j) + 1);
        beta_sample(j) = 0.5*(beta_parallel(j) + beta_perpendicular(j));
    end
    
    alpha = 4.0*pi*epsilon_0*(R^3)*((epsilon_tip - 1)/(epsilon_tip + 2)); % alpha described the polarisability of the sphere (not used in FDM)
    beta = (epsilon_sample - 1)/(epsilon_sample + 1); % surface-response function (depends on the local dielectric properties of the sample)
% 
    fun_PDM = @(t,alpha,beta,d_0,z_0,f_0,n) (f_0.*(exp(-1i*n*2.0*pi*f_0*t)).*(alpha.*(beta + 1.0)./(1.0 - ((alpha.*beta)./(16.0*pi*(R + (d_0 + 0.5*z_0.*(1.0 + sin(2.0*pi*f_0*t)))).^3)))));
    fun_FDM = @(t,L,R,g,beta,d_0,z_0,f_0,n) (f_0.*(exp(-1i*n*2.0*pi*f_0*t)).*((L.*R^2).*((((2.0*L)./R) + (log(R./(4.0*exp(1.0)*L))))./(log((4.0*L)./exp(2)))).*(2.0 + ((beta.*(g - ((R + ((d_0 + 0.5*z_0*(1.0 + sin(2.0*pi*f_0*t)))))./L)).*(log((4.0*L)./(4.0*((d_0 + 0.5*z_0.*(1.0 + sin(2.0*pi*f_0*t)))) + 3.0*R))))./(log(4.0*L./R) - beta.*(g - ((3.0*R + 4.0*((d_0 + 0.5*z_0.*(1.0 + sin(2.0*pi*f_0*t)))))./(4.0*L))).*(log((2.0*L)./(2.0*((d_0 + 0.5*z_0.*(1.0 + sin(2.0*pi*f_0*t)))) + R))))))));
%     fun_FDM = @(t,L,R,g,beta,d_0,z_0,f_0,n) (f_0.*(exp(-1i*n*2.0*pi*f_0*t)).*(((beta.*(g - ((R + ((d_0 + 0.5*z_0*(1.0 + sin(2.0*pi*f_0*t)))))./L)).*(log((4.0*L)./(4.0*((d_0 + 0.5*z_0.*(1.0 + sin(2.0*pi*f_0*t)))) + 3.0*R))))./(log(4.0*L./R) - beta.*(g - ((3.0*R + 4.0*((d_0 + 0.5*z_0.*(1.0 + sin(2.0*pi*f_0*t)))))./(4.0*L))).*(log((2.0*L)./(2.0*((d_0 + 0.5*z_0.*(1.0 + sin(2.0*pi*f_0*t)))) + R)))))));
    
    for j = 1:length(d_0)
        c_n1(j) = integral(@(t) fun_FDM(t,L,R,g,beta,d_0(j),z_0,f_0,1),-T/2,T/2);
        c_n2(j) = integral(@(t) fun_FDM(t,L,R,g,beta,d_0(j),z_0,f_0,2),-T/2,T/2);
        c_n3(j) = integral(@(t) fun_FDM(t,L,R,g,beta,d_0(j),z_0,f_0,3),-T/2,T/2);
        c_n4(j) = integral(@(t) fun_FDM(t,L,R,g,beta,d_0(j),z_0,f_0,4),-T/2,T/2);
        c_n5(j) = integral(@(t) fun_FDM(t,L,R,g,beta,d_0(j),z_0,f_0,5),-T/2,T/2);
    end
%     
%     for j = 1:length(w)
%         c_n1(j) = integral(@(t) fun_FDM(t,L,R,g,beta_sample(j),d_0,z_0,f_0,1),-T/2,T/2);
%         c_n2(j) = integral(@(t) fun_FDM(t,L,R,g,beta_sample(j),d_0,z_0,f_0,2),-T/2,T/2);
%         c_n3(j) = integral(@(t) fun_FDM(t,L,R,g,beta_sample(j),d_0,z_0,f_0,3),-T/2,T/2);
%         c_n4(j) = integral(@(t) fun_FDM(t,L,R,g,beta_sample(j),d_0,z_0,f_0,4),-T/2,T/2);
%         c_n5(j) = integral(@(t) fun_FDM(t,L,R,g,beta_sample(j),d_0,z_0,f_0,5),-T/2,T/2);
%     end
%     
%     [beta_gold,epsilon_gold] = Dielectric_Gold(w);
%     for j = 1:length(w)
%         gold_c_n1(j) = integral(@(t) fun_FDM(t,L,R,g,beta_gold(j),d_0,z_0,f_0,1),-T/2,T/2);
%         gold_c_n2(j) = integral(@(t) fun_FDM(t,L,R,g,beta_gold(j),d_0,z_0,f_0,2),-T/2,T/2);
%         gold_c_n3(j) = integral(@(t) fun_FDM(t,L,R,g,beta_gold(j),d_0,z_0,f_0,3),-T/2,T/2);
%         gold_c_n4(j) = integral(@(t) fun_FDM(t,L,R,g,beta_gold(j),d_0,z_0,f_0,4),-T/2,T/2);
%         gold_c_n5(j) = integral(@(t) fun_FDM(t,L,R,g,beta_gold(j),d_0,z_0,f_0,5),-T/2,T/2);
%         absolute(j) = c_n3(j)/gold_c_n3(j);
%     end
    
%     figure; box on;
%     plot(w,abs(epsilon_gold))
    
%     figure; box on;
%     set(gcf,'Color','w')
%     subplot(2,1,1)
%     plot(w,abs(absolute),'linewidth',1.5)
%     xlim([890 1000]);
%     xlabel('\omega (cm^{-1})')
%     ylabel('s_{3\omega}^{SiC}/s_{3\omega}^{Au}')
%     subplot(2,1,2)
%     plot(w,unwrap(angle(absolute)),'linewidth',1.5)
%     xlim([890 1000]);
%     xlabel('\omega (cm^{-1})')
%     ylabel('\phi_{3\omega}^{SiC} - \phi_{3\omega}^{Au}')
%     set(findall(gcf,'-property','fontsize'),'fontsize',20)
    
    for i = 1:5
        legendInfo{i} = ['s' num2str(i)];
    end
    figure; box on;
    set(gcf,'Color','w')
    plot(d_0./1e-9,abs(c_n1)./abs(c_n1(1)),'linewidth',1.5)
    hold on
    plot(d_0./1e-9,abs(c_n2)./abs(c_n2(1)),'linewidth',1.5)
    hold on
    plot(d_0./1e-9,abs(c_n3)./abs(c_n3(1)),'linewidth',1.5)
    hold on
    plot(d_0./1e-9,abs(c_n4)./abs(c_n4(1)),'linewidth',1.5)
    hold on
    plot(d_0./1e-9,abs(c_n5)./abs(c_n5(1)),'linewidth',1.5)
    hold on
    yline(exp(-1))
    xlim([0 100]);
    legend(legendInfo,'box','off');
    title('Approach Curves')
    xlabel('Tip-Sample Distance (nm)')
    ylabel('s_n, normalised to contact')
    set(findall(gcf,'-property','fontsize'),'fontsize',20)
    
%     for j = 1:length(d_0)
%         c_n1(j) = integral(@(t) fun_PDM(t,alpha,beta,d_0(j),z_0,f_0,1),-T/2,T/2);
%         c_n2(j) = integral(@(t) fun_PDM(t,alpha,beta,d_0(j),z_0,f_0,2),-T/2,T/2);
%         c_n3(j) = integral(@(t) fun_PDM(t,alpha,beta,d_0(j),z_0,f_0,3),-T/2,T/2);
%         c_n4(j) = integral(@(t) fun_PDM(t,alpha,beta,d_0(j),z_0,f_0,4),-T/2,T/2);
%         c_n5(j) = integral(@(t) fun_PDM(t,alpha,beta,d_0(j),z_0,f_0,5),-T/2,T/2);
%     end
%     for i = 1:5
%         legendInfo{i} = ['s' num2str(i)];
%     end
%     figure; box on;
%     set(gcf,'Color','w')
%     plot(d_0./1e-9,abs(c_n1)./abs(c_n1(1)),'--','linewidth',1.5)
%     hold on
%     plot(d_0./1e-9,abs(c_n2)./abs(c_n2(1)),'--','linewidth',1.5)
%     hold on
%     plot(d_0./1e-9,abs(c_n3)./abs(c_n3(1)),'--','linewidth',1.5)
%     hold on
%     plot(d_0./1e-9,abs(c_n4)./abs(c_n4(1)),'--','linewidth',1.5)
%     hold on
%     plot(d_0./1e-9,abs(c_n5)./abs(c_n5(1)),'--','linewidth',1.5)
%     xlim([0 35]);
%     legend(legendInfo,'box','off');
%     title('Approach Curves')
%     xlabel('Tip-Sample Distance (nm)')
%     ylabel('s_n, normalised to contact')
%     set(findall(gcf,'-property','fontsize'),'fontsize',20)
end

function [beta_gold,epsilon_gold] = Dielectric_Gold(w)
    % Ordal et al., Applied Optics, Vol. 22, No. 7, 1983
    epsilon_inf = 1.0;
    wp = 7.25e4; % plasma frequency
    wt = 2.16e2; % damping frequency
    epsilon_gold = epsilon_inf - ((wp^2)./(w.^2 + 1i*w.*wt));
    beta_gold = (epsilon_gold - 1)./(epsilon_gold + 1);
end
