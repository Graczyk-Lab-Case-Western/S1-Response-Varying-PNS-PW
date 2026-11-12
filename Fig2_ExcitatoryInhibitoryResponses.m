%% Figure 2 Script
close all; clear; clc; 

%% USER INPUT NEEDED %%
dataDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Manuscripts' filesep 'PW Manuscript'];
saveDir = [filesep  'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'PNS Prox Dist Comparison' filesep 'percentCoverage' filesep 'manuscript 1 coverage'];
%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
PSTH_Data = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 2a');
ExIn_Data = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 2b');

%% Fig 2a: PSTH Generation
electrodeSet = [91 107];
colors = [0 0 0];

% Excitatory PSTH
time = PSTH_Data.Time';
predMean=PSTH_Data.S12_E107_PredMean;
confidInt = [PSTH_Data.S12_E107_CI_Lower, PSTH_Data.S12_E107_CI_Upper];
plotNormalizedFRAvgExample(predMean, confidInt, time, electrodeSet, '107', colors, saveDir)

% Inhibitory PSTH
time = PSTH_Data.Time';
predMean=PSTH_Data.S12_E91_PredMean;
confidInt = [PSTH_Data.S12_E91_CI_Lower, PSTH_Data.S12_E91_CI_Upper];
plotNormalizedFRAvgExample(predMean, confidInt, time, electrodeSet, '91', colors, saveDir)

%% Fig 2b: Bar Plot - RP1

% Find the rows for RP1
participantRows = strcmp(ExIn_Data.Participant, 'RP1');
RP1_Data = ExIn_Data(participantRows, :);

colors = [190 145 178; 51 30 46]./255; % shades of purple #BE91B2 #734567

totalResponses = [RP1_Data.Excitatory RP1_Data.Inhibitory];
elecPool = sum(totalResponses, 2);
totalResponses = totalResponses./elecPool;

figure
SetFont('Arial', 30)
set(gcf, 'Units', 'inches', 'Position', [3 3 5 3.75])
    
elecIdentityPrevalenceMeans = mean(totalResponses,1);
elecIdentityPrevalenceSEM = std(totalResponses,1)/sqrt(10);
b=bar(elecIdentityPrevalenceMeans,.55,'EdgeColor','none','FaceColor','flat');
b.CData(1,:) = colors(1,:);
b.CData(2,:) = colors(2,:);

hold on
errorbar(elecIdentityPrevalenceMeans,elecIdentityPrevalenceSEM,'Color','k',"LineStyle","none","LineWidth",2)
box off
text(b.XEndPoints, b.YEndPoints+elecIdentityPrevalenceSEM+.02, string(round(elecIdentityPrevalenceMeans.*100,1)), ...
    VerticalAlignment='bottom', HorizontalAlignment='center',FontSize=30);

ylabel('Prevalence (%)')
xlabel('Responsivity Profiles')
xticklabels({'Ex','In'})
set(gcf,'Color','w');
titleString = 'ExInBarGraphShortFractions';
saveFilenamejpg = [saveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

%% Fig 2b: RP1 Stats
[p,h] = ranksum(totalResponses(:,1),totalResponses(:,2));
display(p)

%% Fig 2b: Bar Plot - RP2

% Find the rows for RP1
participantRows = strcmp(ExIn_Data.Participant, 'RP2');
RP2_Data = ExIn_Data(participantRows, :);

colors = [190 145 178; 51 30 46]./255; % shades of purple #BE91B2 #734567

totalResponses = [RP2_Data.Excitatory RP2_Data.Inhibitory];
elecPool = sum(totalResponses, 2);
totalResponses = totalResponses./elecPool;

figure
SetFont('Arial', 30)
set(gcf, 'Units', 'inches', 'Position', [3 3 5 3.75])
    
elecIdentityPrevalenceMeans = mean(totalResponses,1);
elecIdentityPrevalenceSEM = std(totalResponses,1)/sqrt(10);
b=bar(elecIdentityPrevalenceMeans,.55,'EdgeColor','none','FaceColor','flat');
b.CData(1,:) = colors(1,:);
b.CData(2,:) = colors(2,:);

hold on
errorbar(elecIdentityPrevalenceMeans,elecIdentityPrevalenceSEM,'Color','k',"LineStyle","none","LineWidth",2)
box off
text(b.XEndPoints, b.YEndPoints+elecIdentityPrevalenceSEM+.02, string(round(elecIdentityPrevalenceMeans.*100,1)), ...
    VerticalAlignment='bottom', HorizontalAlignment='center',FontSize=30);

ylabel('Prevalence (%)')
xlabel('Responsivity Profiles')
xticklabels({'Ex','In'})
set(gcf,'Color','w');
titleString = 'ExInBarGraphShortFractions';
saveFilenamejpg = [saveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)
