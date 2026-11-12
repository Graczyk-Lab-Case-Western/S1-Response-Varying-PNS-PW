%% Figure 3 Script
close all; clear; clc; 

%% USER INPUT NEEDED %%
dataDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Manuscripts' filesep 'PW Manuscript'];
saveDir = [filesep  'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'PNS Prox Dist Comparison' filesep 'percentCoverage' filesep 'manuscript 1 coverage'];
%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
PSTH_Data = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 3c,d');
activationProfiles = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 3e');

%% Fig 3c,d: PSTH Generation
electrodeSet = [11 68 76];
colors = [0 0 0];

% PSTH example
time = PSTH_Data.Time';
predMean=PSTH_Data.S6_E11_PredMean;
confidInt = [PSTH_Data.S6_E11_CI_Lower, PSTH_Data.S6_E11_CI_Upper];
plotNormalizedFRAvgExample(predMean, confidInt, time, electrodeSet, '107', colors, saveDir)

% PSTH example
time = PSTH_Data.Time';
predMean=PSTH_Data.S6_E68_PredMean;
confidInt = [PSTH_Data.S6_E68_CI_Lower, PSTH_Data.S6_E68_CI_Upper];
plotNormalizedFRAvgExample(predMean, confidInt, time, electrodeSet, '91', colors, saveDir)

% PSTH example
time = PSTH_Data.Time';
predMean=PSTH_Data.S6_E76_PredMean;
confidInt = [PSTH_Data.S6_E76_CI_Lower, PSTH_Data.S6_E76_CI_Upper];
plotNormalizedFRAvgExample(predMean, confidInt, time, electrodeSet, '91', colors, saveDir)

%% Fig 3e: Bar plot of activation profiles - RP1

% find RP1 relevant rows
rp1Rows = contains(activationProfiles.Participant, 'RP1', 'IgnoreCase', true);
rp1Profiles = activationProfiles{rp1Rows, 3:end};
rp1ProfilesFractions = rp1Profiles ./ sum(rp1Profiles, 2);

figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 3.4 2.75]) %[1 1 6.5 2.75]

colors = [0 127 255; 247,240,86; 223 72 40; 166 190 84; 231 140 53; 155 98 167; 114,30,23];
colors = colors/255;

elecIdentityPrevalenceMeans = mean(rp1ProfilesFractions,1);
elecIdentityPrevalenceSEM = std(rp1ProfilesFractions,0,1)/sqrt(10);
b=bar(elecIdentityPrevalenceMeans,'EdgeColor','none','FaceColor','flat');
b.CData(1,:) = colors(1,:);
b.CData(2,:) = colors(2,:);
b.CData(3,:) = colors(3,:);
b.CData(4,:) = colors(4,:);
b.CData(5,:) = colors(5,:);
b.CData(6,:) = colors(6,:);
b.CData(7,:) = colors(7,:);
hold on
errorbar(elecIdentityPrevalenceMeans,elecIdentityPrevalenceSEM,'Color','k',"LineStyle","none","LineWidth",2)
% xticklabels({'On','Sus',"Off",'On+Sus','Sus+Off','On+Off','On+Sus+Off'})
% xtickangle(45)
box off
ylabel({'% of Activation Profiles','per Session'})
xlabel('Activation Profiles')
xticklabels({'','','','','','',''})
ylim([0 1])
titleString = 'ElecIDBarGraphFractions';
saveFilenamejpg = [saveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

% stats
[p,tbl,stats] = kruskalwallis(squeeze(fractionStorage)');
postHocComparisons = multcompare(stats,'CriticalValueType','dunn-sidak');

%% Fig 3e: Bar plot of activation profiles - RP2

% find RP2 relevant rows
rp2Rows = contains(activationProfiles.Participant, 'RP2', 'IgnoreCase', true);
rp2Profiles = activationProfiles{rp2Rows, 3:end};
rp2ProfilesFractions = rp2Profiles ./ sum(rp2Profiles, 2);

figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 3.4 2.75]) %[1 1 6.5 2.75]

colors = [0 127 255; 247,240,86; 223 72 40; 166 190 84; 231 140 53; 155 98 167; 114,30,23];
colors = colors/255;

elecIdentityPrevalenceMeans = mean(rp2ProfilesFractions,1);
elecIdentityPrevalenceSEM = std(rp2ProfilesFractions,0,1)/sqrt(10);
b=bar(elecIdentityPrevalenceMeans,'EdgeColor','none','FaceColor','flat');
b.CData(1,:) = colors(1,:);
b.CData(2,:) = colors(2,:);
b.CData(3,:) = colors(3,:);
b.CData(4,:) = colors(4,:);
b.CData(5,:) = colors(5,:);
b.CData(6,:) = colors(6,:);
b.CData(7,:) = colors(7,:);
hold on
errorbar(elecIdentityPrevalenceMeans,elecIdentityPrevalenceSEM,'Color','k',"LineStyle","none","LineWidth",2)
% xticklabels({'On','Sus',"Off",'On+Sus','Sus+Off','On+Off','On+Sus+Off'})
% xtickangle(45)
box off
ylabel({'% of Activation Profiles','per Session'})
xlabel('Activation Profiles')
xticklabels({'','','','','','',''})
ylim([0 1])
titleString = 'ElecIDBarGraphFractions';
saveFilenamejpg = [saveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)
