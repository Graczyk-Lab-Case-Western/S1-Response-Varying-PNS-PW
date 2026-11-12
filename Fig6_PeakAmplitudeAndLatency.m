%% Figure 6 Script
close all; clear; clc;

%% USER INPUT NEEDED %%
dataDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Manuscripts' filesep 'PW Manuscript'];
saveDir = [filesep  'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'PNS Prox Dist Comparison' filesep 'percentCoverage' filesep 'manuscript 1 coverage'];
%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
data = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 6_1');
pvalData = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 6_2');

% Identification variables 
sesDict = [1:10];
contactDict = ["m2", "m2", "m1", "m1", "m1", "u5", "u5", "u5", "u5", "u4", "u4", "u5"];
contactDictNum = [2,2,1,1,1,5,5,5,5,4,4,5];
condDict = ["Control","-60%","-40%","-20%","0%","20%","40%","60%","80%","100%"];
condNumDict = [1:10];

%% *for non extreme trials* acquire metrics across resp elec and sessions 
% Create variables that will store across sessions
totalPeaksOnset = []; totalPeaksOnsetNorm = [];  totalLatOnset = []; totalLatOnsetNorm = []; 
totalPeaksOffset = [];totalPeaksOffsetNorm = []; totalLatOffset = []; totalLatOffsetNorm = []; 
totalCondOn = []; totalCondOff = [];
trialWPeaksOnsetTotal = cell(length(sesDict),1); trialWPeaksOffsetTotal = cell(length(sesDict),1);
totalSesNumOnset = []; totalContactsOnset = [];totalSesNumOffset = []; totalContactsOffset = [];

for i = 1:10 % number of sessions
    % Get subset of trials
    sessionData = data(data.Session==i,:);
    exPvalBinaryAcrossPhases = pvalData(pvalData.Session==i,:);
    % Acquire variables for given session
    condSesOn = sessionData.CondNumber';
    peaksOnSes = table2array(sessionData(condSesOn>4,4:131));
    latOnSes = table2array(sessionData(condSesOn>4,132:259));
    peaksOffSes = table2array(sessionData(condSesOn>4,260:387));
    latOffSes = table2array(sessionData(condSesOn>4,388:515));

    condSesOn = condSesOn(condSesOn>4);
    condSesOff = condSesOn(condSesOn>4);

    % Find the number of trials
    numTrials = length(condSesOn); % doesn't matter that this is on or off

    % Find all the electrodes corresponding to the session 
    respElecOnSes = find([exPvalBinaryAcrossPhases(:,2).Onset]==1);
    respElecSusSes = find([exPvalBinaryAcrossPhases(:,3).Sustained]==1);
    respElecOffSes = find([exPvalBinaryAcrossPhases(:,4).Offset]==1);
    display(length(respElecOnSes))
    % Store peak amplitude and latency for onset and offset phases per resp elec per trial
    peaksOnSes = peaksOnSes(:,respElecOnSes)';
    latOnSes = latOnSes(:,respElecOnSes)';
    peaksOffSes = peaksOffSes(:,respElecOffSes)';
    latOffSes = latOffSes(:,respElecOffSes)';

    % Remove the trials that are zero or full latency per electrode
    % init var for storing the number of viable trials per electrode
    trialWPeaksPerElecOn = zeros(size(respElecOnSes,1),1);
    trialWPeaksPerElecOff = zeros(size(respElecOffSes,1),1);

    latOnSesNorm = latOnSes;
    latOffSesNorm = latOffSes;

    peaksOnSesNorm = peaksOnSes;
    peaksOffSesNorm = peaksOffSes;

    for e = 1:size(latOnSes,1)
        trialWPeaksPerElecOn(e) = length(latOnSes(e,latOnSes(e,:)~=1 & latOnSes(e,:)~=400));

        meanLat = mean(latOnSes(e,latOnSes(e,:)~=1 & latOnSes(e,:)~=400),2); % only care about suprathreshold conditions
        latOnSesNorm(e,:) = (latOnSes(e,:))./meanLat; 

        meanPeaks = mean(peaksOnSes(e,latOnSes(e,:)~=1 & latOnSes(e,:)~=400),2);
        peaksOnSesNorm(e,:) = (peaksOnSes(e,:))./meanPeaks; 
    end

    for e = 1:size(latOffSes,1)
        trialWPeaksPerElecOff(e) = length(latOffSes(e,latOffSes(e,:)~=1 & latOffSes(e,:)~=400));

        meanLat = mean(latOffSes(e,latOffSes(e,:)~=1 & latOffSes(e,:)~=400),2); % only care about suprathreshold conditions
        latOffSesNorm(e,:) = (latOffSes(e,:))./meanLat; 
        meanPeaks = mean(peaksOffSes(e,latOffSes(e,:)~=1 & latOffSes(e,:)~=400),2);
        peaksOffSesNorm(e,:) = (peaksOffSes(e,:))./meanPeaks; 
    end

    % Resize var to be one long vector
    peaksOnSes = reshape(peaksOnSes, [numTrials*size(respElecOnSes,1),1]);
    peaksOnSesNorm = reshape(peaksOnSesNorm, [numTrials*size(respElecOnSes,1),1]);

    latOnSes = reshape(latOnSes, [numTrials*size(respElecOnSes,1),1]);
    latOnSesNorm = reshape(latOnSesNorm, [numTrials*size(respElecOnSes,1),1]);

    peaksOffSes = reshape(peaksOffSes, [numTrials*size(respElecOffSes,1),1]);
    peaksOffSesNorm = reshape(peaksOffSesNorm, [numTrials*size(respElecOffSes,1),1]);

    latOffSes = reshape(latOffSes, [numTrials*size(respElecOffSes,1),1]);
    latOffSesNorm = reshape(latOffSesNorm, [numTrials*size(respElecOffSes,1),1]);

    % Reformat conditions to be as long as different elec subsets
    condSesOn = condSesOn';
    condSesOn = repelem(condSesOn,length(respElecOnSes)); 
    condSesOff = condSesOff'; 
    condSesOff = repelem(condSesOff,length(respElecOffSes));

    sesNumOn = ones(size(condSesOn,1),1)*sesDict(i);
    sesNumOff = ones(size(condSesOff,1),1)*sesDict(i);
    contactsOn = ones(size(condSesOn,1),1)*contactDictNum(i);
    contactsOff = ones(size(condSesOff,1),1)*contactDictNum(i);

    % Add variables to mega variables
    trialWPeaksOnsetTotal{i} = trialWPeaksPerElecOn;
    trialWPeaksOffsetTotal{i} = trialWPeaksPerElecOff;
    totalPeaksOnset = [totalPeaksOnset; peaksOnSes];
    totalPeaksOffset = [totalPeaksOffset; peaksOffSes];
    totalPeaksOnsetNorm = [totalPeaksOnsetNorm; peaksOnSesNorm];
    totalPeaksOffsetNorm = [totalPeaksOffsetNorm; peaksOffSesNorm];
  
    totalLatOnset = [totalLatOnset; latOnSes];
    totalLatOffset = [totalLatOffset; latOffSes];
    totalLatOnsetNorm = [totalLatOnsetNorm; latOnSesNorm];
    totalLatOffsetNorm = [totalLatOffsetNorm; latOffSesNorm];
    totalCondOn = [totalCondOn; condSesOn];
    totalCondOff = [totalCondOff; condSesOff];
    totalSesNumOnset = [totalSesNumOnset; sesNumOn]; 
    totalContactsOnset = [totalContactsOnset; contactsOn];
    totalSesNumOffset = [totalSesNumOffset; sesNumOff ]; 
    totalContactsOffset = [totalContactsOffset; contactsOff];
end

%% USER INPUT NEEDED %%
metric = totalPeaksOnsetNorm;
metric2 = totalLatOnset;
condition = totalCondOn;
ttlStr = ['OnsetNormPeaksBoxSwarmPlot.jpg'];  
yLabelString='Normalized Peak Latency'; 
%%%%%%%%%%%%%%%%%%%%%%%

%% figure 6a-d: swarmchart

color = [190,145,178]/255; %'#BE91B2' %lavender
darkColor = [154 91 137]/255; %'#9A5B89' %lilac
close
figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 3 3])
hold on

conditionDict = [0 20 40 60 80 100];

for c = 5:10
    % find the trials that correspond to the condition
    trials4Cond = find(condition == condNumDict(c));
    display(length(trials4Cond));
    trials4Cond = find(condition == condNumDict(c)& metric2~=1 & metric2~=400);
    
    trials = metric(trials4Cond);
    condValues = totalCondOn(trials4Cond);
    
    % find values within 10-90% quantiles
    q = quantile(trials,[0.1 0.9]);
    % find trials
    t=trials>q(1) & trials<q(2);
    trials = trials(t);
    condValues=condValues(t);

    % edit Swarm to have no central tendency plotted (line 363)
    Swarm(c,trials,color,'SwarmPointLimit',2000,'SMS',1,'SwarmEdgeAlpha',0);
end

% create linear regression between duration and area of activation
x = condition(metric2~=1 & metric2~=400);
y = metric(metric2~=1 & metric2~=400);
mdl = fitlm(x,y);
plot(4:11, mdl.Coefficients{1,1}+(mdl.Coefficients{2,1}*[4:11]),'Color', 'k', 'LineWidth',1)
display(mdl.Coefficients{2,4})


%ylim([0 3.5]) % -1,7.5 for peak, -1 to 5 for latency
xticks(4:11)
xlim([4 11])
xticklabels({"","0", "20", "40", "60", "80", "100",''})
xlabel('Pulse Width Condition (%)')
ylabel(yLabelString)
% save fig
saveFilenamejpg = [saveDir filesep char(ttlStr)]; 
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)
