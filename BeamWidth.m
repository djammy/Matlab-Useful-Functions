 function [] = BeamWidth()
    clear all

%%  Either load data points from a file
%     Data = importdata('[insert file name]');
%     x = Data.data(:,1);
%     y = Data.data(:,2);

%%    Or create your own position and power parameters
    position = [19 20 21 22 23 23.5 24 24.5 24.6 24.7 24.8 25 25.1 25.2 25.3 25.4 25.5 25.6 25.7 25.8 25.9 26 26.1 26.2 26.3 26.4 26.5 26.6 26.7 26.8 26.9 27 27.1 27.2 27.3 27.4 27.5 27.6 27.7 27.8 27.9 28 28.1 28.2 28.3 28.4 28.5 28.6 28.7 28.8 28.9 29 29.1 29.2 29.3 29.4 29.5 29.6 29.7 29.8 29.9 30 30.1 30.2 30.3 30.4 30.5 30.6 30.7 30.8 30.9 31 31.1 31.2 31.3 31.4 31.5 31.6 31.7 31.8 31.9 32 32.1 32.2 32.3 32.4 32.5 32.6 32.7 32.8 32.9 33 33.1 33.2 33.3 33.4 33.5 33.6 33.7 33.8 33.9 34 34.1 34.2 34.3 34.4 34.5 34.6 34.7 34.8 34.9 35 35.1 35.2 35.3 35.4 35.5 35.6 35.7 35.8 35.9 36 36.1 36.2 36.3 36.4 36.5 36.6 37.1 37.6 38.1 38.6 39.1 40.1 41.1 42.1 43.1];
    power = [59.1 59.2 59.1 59.2 59.1 59.2 59.2 58.8 58.9 58.7 58.4 58 57.7 57.7 57.4 57.2 57.1 56.4 56.7 55.9 55.6 55.2 54.7 53.9 53.7 53.2 52.8 52.7 52 51.5 50.9 50.4 50 49.3 48.8 48.3 47.7 47.2 46.8 46.7 45.2 44.9 44.7 43.7 43.2 42.4 42 41.6 40.8 40.7 39.6 38.8 38.4 37.6 37.1 36.4 35.5 34.9 34.4 33.5 33.1 32.6 31.6 30.9 30.3 29.5 28.8 28.2 27.7 26.9 26.1 25.7 24.8 24.1 23.6 22.9 22.4 21.7 21 20.4 19.7 19.3 18.6 17.4 17.2 16.9 16.2 15.7 15.2 14.7 14 13.6 12.9 12.6 11.9 11.6 11.2 10.4 10 9.6 9.2 8.5 8.3 7.8 7.6 6.9 6.7 6.2 5.7 5.4 4.8 4.6 4.4 4.1 3.7 3.4 3.1 2.8 2.4 2.1 1.9 1.7 1.6 1.4 1.2 0.9 0.8 0.8 0.5 0.3 0.3 0.4 0.4 0.3 0.4 0.3 0.3];
    x = position'; y = power'; % transpose to create column vectors
    
%%  Function Fitting
    objectivefunction = @(params) (FittingFunction(params,x,y));
    
    % Fitting parameters
    MyParams = [max(y),mean(x),1];
    lower = [0,0,0];
    upper = [inf,50,50];
    Iterations = 500;
    Step = 0.001;
    options = optimset('FinDiffRelStep',Step,'MaxIter',Iterations,'MaxFunEvals', Iterations, 'TolFun', 1e-10, 'TolX', 1e-10);
    [params, ~, ~, ~, ~, ~, ~] = lsqnonlin(objectivefunction,MyParams,lower,upper,options);
    
    f = params(1) * (1-cdf('Normal',x,params(2),params(3)));
    df = normpdf(x,params(2),params(3))*sqrt(2*pi*params(3)^2);
    df = df*max(y);
    center = params(2)
    sigma = params(3);
    FWHM = 2*sqrt(2*log(2)) * sigma
    
%%  Plot
    figure
    plot(x,y./max(y),'x','color','r','linewidth',1.5)
    hold on
    plot(x,f./max(y),'k','linewidth',1.5)
    plot(x,df./max(y),'b','linewidth',1.5)
    legend('Data','Fit','Gaussian','interpreter','latex')
    legend boxoff
    xlabel('Sample Stage Position (mm)','interpreter','latex')
    ylabel('Measured Power (arb.)','interpreter','latex')
    set(gca,'FontSize',13,'XColor','k','YColor','k')
    str = {strcat('Center:',num2str(center,3),' (mm)   FWHM:',num2str(FWHM,3),' (mm)')};
    annotation('textbox','String',str,'FitBoxToText','on','Interpreter','latex','Edgecolor','none');
    ax = gca;
    ax.YAxis.Exponent = 2;
    
 end

function Q = FittingFunction(params,x,y)
    f = params(1) * (1-cdf('Normal',x,params(2),params(3)));
    Q = f-y;
end
