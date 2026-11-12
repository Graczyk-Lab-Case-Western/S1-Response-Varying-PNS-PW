%% Figure 1 Script
close all; clear; clc; 

%% USER INPUT NEEDED %%
dataDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Manuscripts' filesep 'PW Manuscript'];
saveDir = [filesep  'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'PNS Prox Dist Comparison' filesep 'percentCoverage' filesep 'manuscript 1 coverage'];

participant = 'RP1'; % RP1 or RP2
nerve = 'Median'; % Median or Ulnar
filenameString = 'rp1MedianCoverage.jpg';
%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
T = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 1b');

%% Convert columns of table to appropriate data type
T.Participant = string(T.Participant);
T.Nerve = string(T.Nerve);
T.Contact = str2double(T.Contact);
T.LocationRegion = string(T.LocationRegion);

%% Find the relevant trials
participantRows = strcmp(T.Participant, participant);
nerveRows = strcmp(T.Nerve, nerve);
trialData = T(participantRows & nerveRows, :);

%% Extract trial locations
total = trialData.LocationRegion;

%% Find the frequency each region is reported across PNS contacts
totalLoc = unique(total);

% initialize variable
maskAppearanceDict{1,1} = "test";
maskAppearanceDict{1,2} = [];

for i = 1:length(total)
    % find if that location has already been added
    idx = find([maskAppearanceDict{:,1}] == total(i));
    if isempty(idx)
        maskAppearanceDict{end+1,1} = total(i);
        maskAppearanceDict{end,2} = 1;
    else
        maskAppearanceDict{idx,2} =maskAppearanceDict{idx,2} + 1;
    end
end

% divide the count by the max reported region
maskAppearanceDict = maskAppearanceDict(2:end, :); % Remove the initial test entry

% normalize the counts to the number of trials in that subset
normalizer = max([maskAppearanceDict{:,2}]);
display(normalizer)
for i = 1:size(maskAppearanceDict,1)
    maskAppearanceDict{i,2} = maskAppearanceDict{i,2}/normalizer;
end

%% Make overlap hand figure

if strcmp(nerve, 'Ulnar')
    color = [255 133 133]/255; % coral
else
    color = [124 151 222]/255; % blue
end

plotQuarterLocFreq(maskAppearanceDict,color) 

% Save the location drawing
saveFilenamejpg = [saveDir filesep filenameString];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',900)

