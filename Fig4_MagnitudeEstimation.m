%% Figure 4 Script
close all; clear; clc;

%% USER INPUT NEEDED %%
dataDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Manuscripts' filesep 'PW Manuscript'];
saveDir = [filesep  'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'PNS Prox Dist Comparison' filesep 'percentCoverage' filesep 'manuscript 1 coverage'];
%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
data = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 4c,e');
% coeffs for sigmoidal fit per session were generated via
% the Sigmoidalcurvefit_PWInt.m function (accessible in the HelperFunctions
sigmoidalFitCoeffs = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 4c,d,e');

%% Fig 4c
varInterest = 4; % Column of the data that you are interested in analyzing 

%% Specify colors
m1 = [15,181,174]/255;%'#0FB5AE'; % teal
m2 = [64,70,202]/255;%'#4046CA'; % purple
u4 = [246,133,17]/255;%'#F68511'; % orange
u5 = [222,61,130]/255;%'#DE3D82'; % pink

%% Load data and separate by session
x = unique(data(:,3));
x=x{:,1};
Nm = numel(x); % Number of sessions
separateData = cell(Nm,1); % Stores data per session

c = unique(data(:,4));
c=c{:,1};
numCond = numel(c); % Number of conditions

% Remove control trials
c=c(2:end);
numCond=numCond-1;
    
condData = cell(numCond,1); % Stores data per cond

y_mean = zeros(numCond,1); 
y_min = zeros(numCond,1);
y_max = zeros(numCond,1);
y_SEM = zeros(numCond,1);
    
for idx = 1:Nm
    tmp = find(data.Session == x(idx));
    separateData{idx} = table2array(data(tmp,3:end));
end

for idx = 1:Nm
    figure
    SetFont('Arial', 12)
    set(gcf, 'Units', 'inches', 'Position', [1 1 2.25 3])

    label = idx+3; % Label indicates the session identifier
    
    sessionData = separateData{idx};
    
    % Remove the rows with control condition
    omitTrials = find(sessionData(:,2) == -100);
    sessionData(omitTrials,:)= [];
    for m_idx = 1:numCond
        tmp = find(sessionData(:,2) == c(m_idx));
        condData{m_idx} = sessionData(tmp,:);
    
        y_mean(m_idx) = mean(condData{m_idx}(:,varInterest));
        y_min(m_idx) = min(condData{m_idx}(:,varInterest));
        y_max(m_idx) = max(condData{m_idx}(:,varInterest));
        y_SEM(m_idx) = std(condData{m_idx}(:,varInterest))/sqrt(length(condData{m_idx}(:,varInterest)));
    end

    %% Plot individual data points

    if any([1:2] == idx)
        color = m2; % Median 2 - purple
        contact = 'M2';
    elseif any([3:5] == idx)
        color = m1; % Median 1 - teal
        contact = 'M1';
    elseif any([6:9,13:14] == idx)
        color = u5; % Ulnar 5 - pink
        contact = 'U5';
    else
        color = u4; % Ulnar 4 - orange
        contact = 'U4';
    end
    hold on
    
    % MUST DISABLE CENTER TENDENCY HORIZONTAL LINE IN SWARM LINE 363
    Swarm(-60,sessionData(sessionData(:,2)==-60,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
    Swarm(-40,sessionData(sessionData(:,2)==-40,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
    Swarm(-20,sessionData(sessionData(:,2)==-20,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
    Swarm(0,sessionData(sessionData(:,2)==0,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
    Swarm(20,sessionData(sessionData(:,2)==20,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
    Swarm(40,sessionData(sessionData(:,2)==40,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
    Swarm(60,sessionData(sessionData(:,2)==60,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
    Swarm(80,sessionData(sessionData(:,2)==80,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
    Swarm(100,sessionData(sessionData(:,2)==100,4),color,'DistributionWidth', 5,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')

    %% Need to load sigmoidalFitCoeffs.mat
    A = sigmoidalFitCoeffs.Coeff_A(idx);
    B = sigmoidalFitCoeffs.Coeff_B(idx);
    tau = sigmoidalFitCoeffs.Coeff_tau(idx);
    t0 = sigmoidalFitCoeffs.Coeff_t0(idx);
    offset = sigmoidalFitCoeffs.Coeff_offset(idx);
    xfit = [-60:0.1:100];
    yfit = (A*exp(-B*exp(-(1/tau)*(xfit-t0)))).*heaviside(xfit+60)+offset; % changed to exclude data past -60
    plot(xfit,yfit,'LineWidth',3,'Color','w')
    plot(xfit,yfit,'LineWidth',2,'Color',[color .5])
    scatter(-60:20:100,y_mean,30,'d','filled','MarkerFaceColor',color,'MarkerFaceAlpha',1)
    hold off

    xlabel('Pulse Width Conditions (%)');
    ylabel('Normalized Perceived Intensity');
    xticks(-60:20:100);
    ylim([0 4.5]);
    xlim([-60 100]);
    set(gca,'YGrid','on'); 

    title([contact ' Sigmoidal Fit']);
    
    fileName = "Sigmoid_DataPts_NormalizedBlock_"+string(label);
   
    saveFilenamejpg = [saveDir filesep char(fileName) '.jpg'];
    %exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)
end

%% Fig 4d
figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 2.25 3])

for idx = 1:14

    label = idx+3; % Label indicates the session identifier
    
    aH = gca;
    hold(aH, 'on');
    
    if any([1:2] == idx)
        color = m2; % Median 1 - teal
    elseif any([3:5] == idx)
       color = m1; % Median 2 - purple
    elseif any([6:9,13,14] == idx)
        color = u5; % Ulnar 5 - pink
    else
        color = u4; % Ulnar 4 - orange
    end
    
    A = sigmoidalFitCoeffs.Coeff_A(idx);
    B = sigmoidalFitCoeffs.Coeff_B(idx);
    tau = sigmoidalFitCoeffs.Coeff_tau(idx);
    t0 = sigmoidalFitCoeffs.Coeff_t0(idx);
    offset = sigmoidalFitCoeffs.Coeff_offset(idx);
    xfit = [-60:0.1:100];
    yfit = (A*exp(-B*exp(-(1/tau)*(xfit-t0)))).*heaviside(xfit+60)+offset; % changed to exclude data past -60

    plot(xfit,yfit,'LineWidth',1,'Color',[color 1])

    xlabel(aH, 'Pulse Width Conditions (%)');
    ylabel(aH, 'Normalized Perceived Intensity');
    xticks(aH, -60:20:100);
    ylim([0 4.5]);
    xlim([-60 100]);
    set(aH,'YGrid','on'); 
    title(aH, 'Sigmoidal Fits Per Session');    
end

fileName = "MultipleSigmoid_NormalizedBlock";
saveFilenamejpg = [saveDir filesep char(fileName) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

%% Fig 4e

% Specify colors
color = [190,145,178]/255; %'#BE91B2' %lavender
darkColor = [154 91 137]/255; %'#9A5B89' %lilac

y_mean = zeros(numCond,1); 
y_min = zeros(numCond,1);
y_max = zeros(numCond,1);
y_SEM = zeros(numCond,1);

data = table2array(data(:,3:end));
for m_idx = 1:numCond
    tmp = find(data(:,2) == c(m_idx));
    condData{m_idx} = data(tmp,:);

    y_mean(m_idx) = mean(condData{m_idx}(:,varInterest));
    y_min(m_idx) = min(condData{m_idx}(:,varInterest));
    y_max(m_idx) = max(condData{m_idx}(:,varInterest));
    y_SEM(m_idx) = std(condData{m_idx}(:,varInterest));%/sqrt(length(condData{m_idx}(:,varInterest)));
end
    
% Plot individual data points
figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 2.25 3])
% MUST DISABLE CENTER TENDENCY HORIZONTAL LINE IN SWARM LINE 363
Swarm(-60,data(data(:,2)==-60,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
Swarm(-40,data(data(:,2)==-40,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
Swarm(-20,data(data(:,2)==-20,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
Swarm(0,data(data(:,2)==0,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
Swarm(20,data(data(:,2)==20,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
Swarm(40,data(data(:,2)==40,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
Swarm(60,data(data(:,2)==60,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
Swarm(80,data(data(:,2)==80,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')
Swarm(100,data(data(:,2)==100,4),color,'SwarmPointLimit',2000, 'DistributionWidth', 5,'CLW',0.001, 'CC', darkColor,'SMS',5,'SwarmEdgeAlpha',0,'CM','Mean')

A = sigmoidalFitCoeffs.Coeff_A(15);
B = sigmoidalFitCoeffs.Coeff_B(15);
tau = sigmoidalFitCoeffs.Coeff_tau(15);
t0 = sigmoidalFitCoeffs.Coeff_t0(15);
offset = sigmoidalFitCoeffs.Coeff_offset(15);
xfit = [-60:0.1:100];
yfit = (A*exp(-B*exp(-(1/tau)*(xfit-t0)))).*heaviside(xfit+60)+offset; % changed to exclude data past -60
plot(xfit,yfit,'LineWidth',3,'Color','w')
plot(xfit,yfit,'LineWidth',2,'Color',color)
scatter(-60:20:100,y_mean,30,'d','filled','MarkerFaceColor',darkColor,'MarkerFaceAlpha',1)

xlabel('Pulse Width Conditions (%)');
ylabel('Normalized Perceived Intensity');
xticks(-60:20:100);
ylim([0 4.5]);
xlim([-60 110]);
set(gca,'YGrid','on'); 

title('Aggregate Sigmoidal Fit');

fileName = "AllData_Sigmoid_DataPts_NormalizedBlock";
saveFilenamejpg = [saveDir filesep char(fileName) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

% stats between conditions
[pvalAnova,t,stats]  = anova1(data(:,4),data(:,2));
results = multcompare(stats);
