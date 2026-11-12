%% Figure 5 Responsive Electrodes across PW
close all; clear; clc;

%% USER INPUT NEEDED %%
dataDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Manuscripts' filesep 'PW Manuscript'];
saveDir = [filesep  'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'PNS Prox Dist Comparison' filesep 'percentCoverage' filesep 'manuscript 1 coverage'];
%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
allStorage = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 5_1');
shapesAll = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 5_2');
% convert tables to arrays
allStorage = table2array(allStorage);
shapesAll = table2array(shapesAll);
sesDict = [1:10];

%% Fig 5a
% identification variables 
sesDict = [1:10];
contactDict = ['M2'; 'M2'; 'M1'; 'M1'; 'M1'; 'U5'; 'U5'; 'U5'; 'U5'; 'U4'; 'U4'; 'U5'];
sesNum4Contact = [1 2 1 2 3 0 0 1 2 1 2 3];
contactDictNum = [2,2,1,1,1,5,5,5,5,4,4,5];
condDict = ["Control","-60%","-40%","-20%","0%","20%","40%","60%","80%","100%"];
condNumDict = [1:10];

% initialize variable for storage
absCondStorage = zeros(length(condNumDict),length(sesDict));
elecNumPhaseStorage = zeros(3,length(condNumDict),length(sesDict));

% determine color map
lineDesign = [":",":", "--", "--", "--", ":",":",":",":","--","--",":"]; % diff style per contact
cool = '#7C9DDE';%[124 157 222]/255;
warm = '#FF8585';%[255 133 133]/255;
colorSet = [cool;cool;cool;cool;cool;warm;warm;warm;warm;warm;warm;warm];

%% gather fractions per session per condition
for s = [1:10] % number of sessions    
    %% find the fractions per PW
    for c = [1:10]
        
        % filter for elec active in that phase across the whole session
        elecAll = allStorage(allStorage(:,1)==sesDict(s)&allStorage(:,2+c)==1,2);
        
        % extract the shapes of the responsive elec for that condition
        shapes4Cond = shapesAll(shapesAll(:,2)==sesDict(s) & shapesAll(:,3)==c,:);

        % find the union of all responsive electrodes
        numAllElec = length(elecAll);

        absCondStorage(c,s) = numAllElec;

        elecNumPhaseStorage(:,c,s) = sum(shapes4Cond(:,4:6),1);
    end
end

% all session traces are grey, and average is plotted in a color
sesOfInterest = [1:10];

% find average across sessions
avgRespElecPerCond = mean(absCondStorage(:,sesOfInterest),2);
stdRespElecPerCond = std(absCondStorage(:,sesOfInterest),0,2)/sqrt(length(absCondStorage(sesOfInterest)));

pvalSlope = zeros(12,1);
slope = zeros(12,1);

figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 3.5 3.5])

hold on
for j = sesOfInterest % number of sessions we are analyzing
    % extract the data (which session and phase)
    % find the union of electrodes that are responsive for a given
    % condition in a session
    plot(absCondStorage(:,j),lineDesign(j),'LineWidth',2,'Color',colorSet(j,:))
    % display(max(absCondStorage(:,j)))
    xlabel('Pulse Width Condition (%)')
    ylabel({'Total # Responsive Electrodes', 'in All Epochs'})

    %find slope of suprathreshold conditions
    mdl=fitlm(-60:20:100,absCondStorage(2:10,j));
    pvalSlope(j) = table2array(mdl.Coefficients(2,4));
    slope(j) = table2array(mdl.Coefficients(2,1));
end

plot(avgRespElecPerCond,'LineWidth',2,'Color','k')
y_low = avgRespElecPerCond-stdRespElecPerCond;
y_high = avgRespElecPerCond+stdRespElecPerCond;

pH = patch([[1:10] fliplr([1:10])], [y_low' fliplr(y_high')], 'k');
pH.FaceAlpha = 0.3;
pH.LineStyle = 'none';

% lgnd = legend('M2 Sessions = 2', '','M1 Sessions = 3','','','U5 Sessions = 3','', 'U4 Sessions = 2','','', 'Average # Responsive Electrodes','');
% lgnd.Location = "northwest";
% legend('boxoff')              
hold off
xlim([1 10])
xticks([1:10])
ylim([-1 35])
xticklabels({'Control', '-60', '-40', '-20', '0', '20', '40', '60', '80', '100'})
%set(gca,'fontsize',22)
% lgnd.FontSize = 22;

% save figure
ttlStr = 'RespExElecNumbersPatchANOVADunnettV2.jpg';    
%exportgraphics(gcf,[saveDir filesep ttlStr],'Resolution',1200)
 
% STATS compare the responsive electrodes across PW 
% data = absCondStorage(:,sesOfInterest)';
% [p,~,stats]=kruskalwallis(data);
% postHocComparisons = multcompare(stats,'CriticalValueType','dunn-sidak');

% gather fractions per session per condition
for s = [1:10] % number of sessions    
    %% find the fractions per PW
    for c = [1:10]
        
        % filter for elec active in that phase across the whole session
        elecAll = allStorage(allStorage(:,1)==sesDict(s)&allStorage(:,2+c)==1,2);
        
        % extract the shapes of the responsive elec for that condition
        shapes4Cond = shapesAll(shapesAll(:,2)==sesDict(s) & shapesAll(:,3)==c,:);

        % find the union of all responsive electrodes
        numAllElec = length(elecAll);

        absCondStorage(c,s) = numAllElec;

        elecNumPhaseStorage(:,c,s) = sum(shapes4Cond(:,4:6),1);
    end
end

% inset figure: slopes across on, sus, and off
% conduct line-slope test for responsive electrodes
pvalSlope = zeros(12,4);
slope = zeros(12,4);
sesOfInterest = [1:10];
s
for i = 1:3 % which phases we are looking at
    for j = [sesOfInterest] % number of sessions we are analyzing
       
        % extract the data (which session and phase)
        respElecPerCond = elecNumPhaseStorage(i,:,j);
        
        %find slope of suprathreshold conditions
        mdl=fitlm(-60:20:100,respElecPerCond(2:10));
        pvalSlope(j,i) = table2array(mdl.Coefficients(2,4));
        slope(j,i) = table2array(mdl.Coefficients(2,1));
    end

end

% find the slope and pval of all epochs
for j = [sesOfInterest] % number of sessions we are analyzing 
    % extract the data (which session and phase)
    respElecPerCond = sum(elecNumPhaseStorage(:,:,j),1);
    
    %find slope of suprathreshold conditions
    mdl=fitlm(-60:20:100,respElecPerCond(2:10));
    pvalSlope(j,4) = table2array(mdl.Coefficients(2,4));
    slope(j,4) = table2array(mdl.Coefficients(2,1));
end

% create figure (box chart of slopes per session for each phase)
colors = [190,145,178;190,145,178;190,145,178]./255; % purple

sesOfInterest = [1:10];
figure
SetFont('Arial', 14)
set(gcf, 'Units', 'inches', 'Position', [1 1 2 4])%.5 2 in manuscript
yline(0,'--','Color',[0.3 0.3 0.3],'LineWidth',2)
hold on
boxchart(ones(1,length(sesOfInterest)),slope(sesOfInterest,1),'MarkerStyle','none','LineWidth',2,"WhiskerLineColor",colors(1,:));
boxchart(ones(1,length(sesOfInterest))*2,slope(sesOfInterest,2),'MarkerStyle','none','LineWidth',2,"WhiskerLineColor",colors(2,:));
boxchart(ones(1,length(sesOfInterest))*3,slope(sesOfInterest,3),'MarkerStyle','none','LineWidth',2,"WhiskerLineColor",colors(3,:));
boxchart(ones(1,length(sesOfInterest))*4.5,slope(sesOfInterest,4),'MarkerStyle','none','LineWidth',2,"WhiskerLineColor",colors(3,:));

colororder(colors)

%xlabel('Epochs')
%ylabel('Slopes')
xticks([1 2 3 4.5])
xticklabels({"Onset", "Sustained", "Offset","All"})
ylim([-0.01 .20])
%yticks(-0.1:.1:.3)

%set(gca,"FontSize",45)
set(gcf, 'color', 'w');  %'none'
yticklabels({0,'','',.2})
xtickangle(50)

saveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data'  filesep 'Manuscript1_Analysis' filesep 'ElectrodeIdentities'];
ttlStr = 'SlopesRespExElecOverSupraPWANOVADunnettV2.jpg';    
%exportgraphics(gcf,[saveDir filesep ttlStr],'Resolution',1200)

% STATS to compare each group of slopes to zero
zeroSlopeResults = zeros(1,4);
for phase = 1:4
    [zeroSlopeResults(phase),~] = signrank(slope(sesOfInterest,phase));
end

% STATS compare the responsive electrodes across PW 
[p,~,stats]=kruskalwallis(slope(sesOfInterest,1:3));
postHocComparisons = multcompare(stats,'CriticalValueType','dunn-sidak');

%% Fig 5b
absStorage = zeros(10 ,6,length(sesDict));

for s = [1:10] % number of sessions
    % find the fractions per PW

    for c = 10
        % filter for elec active in that phase across the whole session
        elecAll = allStorage(allStorage(:,1)==sesDict(s)&allStorage(:,2+c)==1,2);
        
        % extract the shapes of the responsive elec for that condition
        shapesIn100 = shapesAll(shapesAll(:,2)==sesDict(s) & shapesAll(:,3)==c,:);

        % remove the elec that has no responsitivity in this condition
        idxToRemove = find(sum(shapesIn100(:,4:6) == [0 0 0],2)==3);
        shapesIn100(idxToRemove,:) = [];

        numAllElec = size(shapesIn100,1);

        absStorage(c,:,s) = [0 numAllElec 0 0 0 numAllElec];
    end
    
    for c = 1:9
        % initializing variables for fractions for pie charts
        notResp = [];
        sameResp = [];
        diffPhase = [];
        samePhaseAdded = [];
        samePhaseSubtracted = [];

        % find the shapes for a given cond the group of elec responsive at
        % 100%
        shapes4Cond = shapesAll(shapesAll(:,2)==sesDict(s)&shapesAll(:,3)==c,:);
        shapes4Cond(idxToRemove,:) = [];

        % find identity of the pool of electrodes
        % for each electrode see if it matches or how it differs
        for e = 1:size(shapes4Cond,1)
            if isequal(shapes4Cond(e,4:6), shapesIn100(e,4:6))
                sameResp = [sameResp shapes4Cond(e,1)];
            elseif sum(shapes4Cond(e,4:6)) == 0
                notResp = [notResp shapes4Cond(e,1)];
            elseif ismember(2,shapes4Cond(e,4:6)+shapesIn100(e,4:6)) && sum(shapes4Cond(e,4:6)) > sum(shapesIn100(e,4:6)) 
                samePhaseAdded = [samePhaseAdded shapes4Cond(e,1)];
            elseif ismember(2,shapes4Cond(e,4:6)+shapesIn100(e,4:6)) && sum(shapes4Cond(e,4:6)) < sum(shapesIn100(e,4:6)) 
                samePhaseSubtracted = [samePhaseSubtracted shapes4Cond(e,1)];
            else
                diffPhase = [diffPhase shapes4Cond(e,1)];
            end
        end

        % get absolutes
        absStorage(c,:,s) = [length(notResp) length(sameResp) length(samePhaseAdded) length(samePhaseSubtracted) length(diffPhase) numAllElec];
      
    end

end

% rearrange abstorage for plotting purposes
fineResAbsStorage = [absStorage(:,2,:) absStorage(:,4,:) absStorage(:,3,:) absStorage(:,5,:) absStorage(:,1,:)]; 

addResp = [154 91 137]/255; % lavender #9A5B89
diffResp = [173 173 173]/255; % dark grey #ADADAD
subResp = [194 153 183]/255; % light purple #C299B7
sameResp = [103 60 92]/255; % dark purple #9A5B89
noResp = [224 224 224]/255; % light grey #E0E0E0

colors = [sameResp; subResp; addResp; diffResp; noResp];
figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 3 3.5])

% find max electrodes
elecBehaviorPW = sum(fineResAbsStorage(:,1:5,:),3);
elecPool = elecBehaviorPW(10,1);

bar(1:10, sum(fineResAbsStorage(:,1:5,:),3)/elecPool, 'stacked', 'EdgeColor','none');

colororder(colors)
ylim([0 1])
xticklabels({'Control', '-60', '-40', '-20', '0', '20', '40', '60', '80', '100'})
xlabel('Pulse Width Condition (%)')
ylabel({'% of Responsive Electrodes'})
%set(gca,'FontSize',22)
set(gca,'Color','w');
%pbaspect([1 1 1])
 
box off
%legend(["Same Responsivity as 100%", "Subtracted Phases from Responsivity at 100%","Added Phases to Responsivity at 100%","Responsive in Phases Not Present at Responsivity at 100%","Not Responsive"],'Location','southoutside');

% save figure
plotSaveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data'  filesep 'Manuscript1_Analysis' filesep 'ElectrodeIdentities'];
titleString = 'RespElecBehaviorFrom100%_V2';
saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)
