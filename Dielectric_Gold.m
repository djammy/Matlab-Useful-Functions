function [] = Dielectric_Gold()
    % Ordal et al., Applied Optics, Vol. 22, No. 7, 1983
    epsilon_inf = 1.0;
    w = linspace(1.0,2e4,1000); % in cm^-1
    wp = 7.25e4; % plasma frequency
    wt = 2.16e2; % damping frequency
    epsilon = epsilon_inf - ((wp^2)./(w.^2 + 1i*w.*wt));
    figure; box on;
    set(gcf,'Color','w')
    loglog(w,-real(epsilon),w,imag(epsilon),'linewidth',2)
    hold on
    
    [wbennett,e1,e2] = Bennett();
    loglog(wbennett,e1,'o','markersize',10)
    hold on
    loglog(wbennett,e2,'x','markersize',10)
    
    [wbrandli,e1,e2] = Brandli();
    loglog(wbrandli,e1,'s','markersize',10)
    hold on
    loglog(wbrandli,e2,'^','markersize',10)
    hold off
    ylim([1e0 1e6]);
    xlim([1e0 1e5]);
    title('$\rm \textbf{Gold\,\,Dielectric\,\,Response}\,\, \tilde{\epsilon} = \epsilon_1 + i\epsilon_2$','Interpreter','Latex')
    legend('Drude -\epsilon_1','Drude \epsilon_2','Bennett -\epsilon_1','Bennett \epsilon_2','Brandli -\epsilon_1','Brandli \epsilon_2','box','off');
    xlabel('\omega (cm^{-1})')
    ylabel('-\epsilon_1 and \epsilon_2')
    set(findall(gcf,'-property','fontsize'),'fontsize',20)
end

function [w,e1,e2] = Bennett()
    w = [3.13 3.33 3.57 3.85 4.17 4.55 5.00 5.56 6.25 7.14 8.33 10.00 12.5 14.3 16.7 20.0 25.0 33.3];
    w = w.*1e2;
    e1 = [3.69e4 3.37e4 3.06e4 2.73e4 2.41e4 2.08e4 1.77e4 1.48e4 1.22e4 9.51e3 7.14e3 5.05e3 3.29e3 2.54e3 1.88e3 1.31e3 8.39e2 4.75e2];
    e2 = [2.54e4 2.17e4 1.84e4 1.53e4 1.24e4 9.89e3 7.67e3 5.78e3 4.19e3 2.86e3 1.84e3 1.09e3 5.68e2 3.83e2 2.42e2 1.41e2 7.25e1 3.07e1];
end

function [w,e1,e2] = Brandli()
    w = [3.14e1 3.72e1 4.24e1 5.00e1 6.06e1 6.99e1 8.00e1 9.01e1 1.00e2 1.10e2 1.20e2 1.30e2 1.40e2 1.50e2];
    e1 = [8.62e4 8.74e4 9.47e4 9.18e4 9.87e4 9.60e4 9.97e4 1.00e5 1.06e5 1.03e5 1.04e5 9.72e4 9.66e4 8.51e4];
    e2 = [6.23e5 5.37e5 4.81e5 4.00e5 3.37e5 2.82e5 2.47e5 2.15e5 1.93e5 1.68e5 1.49e5 1.30e5 1.14e5 1.00e5];
end