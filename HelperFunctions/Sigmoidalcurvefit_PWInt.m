function [coeff, MSE] = Sigmoidalcurvefit_PWInt(PW, intensity,label,saveDir)

% Fitting a Gompertz curve using lsqcurvefit
% Written by Emily Graczyk elg46@case.edu
% Adapted by Preethisiri Bhat pxb399@case.edu

% Gompertz curve equation:
% y(t)=a*exp(-b*exp(-ct))

% Load in your data as two variables: the x and y coordinates of
%your dataset that you're trying to fit the gompertz curve to. 
%close all; Commented out for other code in firstPassPlots.m to work 7/29/2023 
xdata = PW; % Independent variable
ydata = intensity; % Dependent variable

% Set up your mean squared error (MSE) to be infinite so that you can try a few
%starting points for lsqcurvefit and select the best one
MSE=inf;

% A looping variable - can loop any number of times. More loops = better estimate of global minimum       
iterations = 50;

% Create vector to store MSE values per iteration
MSEstorage = zeros(iterations,1);
% Create vector to store coefficient values per iteration
coeffStorage = zeros(iterations,5);
% Save the indices where the coefficients for global minimum were updated b/c the MSE was
% lower
updates = [];


% Try a few different starting conditions so you can find a global minimum
%(hopefully)
 for k=1:iterations 
        
 % For Gompertz - you have 5 coefficients, labeled here as th1 through th5
 
 % This code selects a random starting point for each coefficient (theta), using the
 %expected range for this specific application. You would adjust this to
 %fit your expected ranges for your dataset/scenario.

 % For PB's PW/PI dataset:
    % th1 = coefficient A = slope of one curve = asymptote 
    th1 = rand()*4.5; % Varies between 0 and 4, 4 was chosen because it 
    %was the asymptote

    %th2 = tau = "horizontal stretch"
    th2 = rand()*40; % Varies between 0 and 40, 40 was chosen because it
    %produced the best fit qualitatively
    
    %th3 = t0 = horizontal shift
    th3 = rand()*40-20; % Varies between -20 and 20
    
    %th4 = vertical offset = y intercept
    th4 = 0; % Set to 0 because we want y intercept to be 0
    
    %th5 = coefficient B = slope of the other curve
    th5 = rand()*4.5; % Varies between 0 and 4
    
    % Organize all Gompertz coefficients into a vector
    thIN = [th1 th2 th3 th4 th5]; % Vector of theta estimates, to put in lsqcurvefit

    % Run lsqcurvefit using your initial coefficient estimates. Lsqcurvefit will then find a local minimum for each coefficient.
    % Optimal estimates of thetas are in thOUT
    lb = [0 0 -100 0 0]; % lower bound
    ub = [4.5 40 100 0 4.5]; % upper bound
    [thOUT, resnorm, residual] = lsqcurvefit(@gompertzfit,thIN,xdata,ydata,lb,ub);

    % Store the coefficients and MSE
    MSEstorage(k) = MSE;
    coeffStorage(k,:) = thOUT;
    
    % Determine if this iteration resulted in less mean squared error than the
    %previous run(s)
    if mean(residual.^2) < MSE
        % If it did, save these thetas for later, otherwise, discard and
        %run again
        MSE=mean(residual.^2);
        A=thOUT(1); 
        B=thOUT(5); 
        tau=thOUT(2);
        t0=thOUT(3);
        offset=thOUT(4);

        updates = [updates, k];
        % Add coefficients into variable that gets outputted 
        coeff = [A, B, tau, t0, offset];
    end
 end

 %% Figure Generation
% Plot the resulting fit line along with the original dataset,
%to qualitatively see how good the fit is
xfit = [-60:0.1:100];
%yfit = (A*exp(-B*exp(-(1/tau)*(xfit-t0)))).*heaviside(xfit-t0)+offset;
yfit = (A*exp(-B*exp(-(1/tau)*(xfit-t0)))).*heaviside(xfit+60)+offset; % changed to exclude data past -60

figure
hold on
plot(xfit,yfit,'LineWidth',2)
scatter(xdata,ydata,[],'red','filled')
ylim([-0.5 4.5])
title('Session '+string(label)+', MSE: '+string(MSE), 'FontSize', 14)
xlabel('Pulse Width Conditions (% of Sensory Dynamic Range)','FontSize', 14)
ylabel('Scaled Perceived Intensity','FontSize', 14)
hold off

fileName = "Estimation"+string(label);
saveFilenamejpg = [saveDir filesep char(fileName) '.jpg'];
%saveas(gcf,saveFilenamejpg);

%Plot just the fit line with grid on for the axes
figure 
plot(xfit,yfit,'LineWidth',2)
ylim([-0.5 4.5])
title('Session '+string(label), 'FontSize', 14)
xlabel('Pulse Width Conditions (% of Sensory Dynamic Range)','FontSize', 14)
ylabel('Scaled Perceived Intensity','FontSize', 14)
grid on

fileName = "CurveFit"+string(label);
saveFilenamejpg = [saveDir filesep char(fileName) '.jpg'];
%saveas(gcf,saveFilenamejpg);

%Plot the variation of the coefficients for the iterations with the lowest
%MSE to observe how consistent they are
figure
boxplot(coeffStorage(updates(end):iterations,:),'labels',{'A','tau','horz shift','y int','B'})
title('Variability across Optimal Coefficient Estimates for Session '+string(label),'FontSize', 14)
ylabel('Coefficient Values','FontSize', 14)
set(findall(gcf,'-property','FontSize'),'FontSize',14)

fileName = "CoeffVariability"+string(label);
saveFilenamejpg = [saveDir filesep char(fileName) '.jpg'];
%saveas(gcf,saveFilenamejpg);
end
       