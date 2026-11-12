%% Figure 8 Script
close all; clear; clc;

%% USER INPUT NEEDED %%
dataDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Manuscripts' filesep 'PW Manuscript'];
saveDir = [filesep  'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'PNS Prox Dist Comparison' filesep 'percentCoverage' filesep 'manuscript 1 coverage'];
%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
data = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 8');

sesOfInterest = 1:10;
numRepeats = 1000;
sesDict = 1:10;
condNumDict = 1:10;

%% concatenate all the sessions together
cond = [];
int = [];
phaseAvgRespElecNorm = [];

% initialize storage variables pertaining to linear regression per session
r2Chance = zeros(1*numRepeats, size(sesDict,2),3);
adjR2Chance = zeros(1*numRepeats, size(sesDict,2),3);
pvalChance = zeros(1*numRepeats, size(sesDict,2),3);

r2Chance_sigPred = zeros(1*numRepeats, size(sesDict,2),3);
adjR2Chance_sigPred = zeros(1*numRepeats, size(sesDict,2),3);
pvalChance_sigPred = zeros(1*numRepeats, size(sesDict,2),3);

r2 = zeros(4, size(sesDict,2));
nullMdl = zeros(4, size(sesDict,2));

adjR2 = zeros(3, size(sesDict,2));
rmse = zeros(3, size(sesDict,2));

pval = zeros(3, size(sesDict,2));
numPred = zeros(3, size(sesDict,2));

r2_sigPred = zeros(3, size(sesDict,2));
adjR2_sigPred = zeros(3, size(sesDict,2));
pval_sigPred = zeros(3, size(sesDict,2));

testR2AboveChance = zeros(3, size(sesDict,2));
testR2AboveChance_sigPred = zeros(3, size(sesDict,2));
testAdjR2AboveChance = zeros(3, size(sesDict,2));
testAdjR2AboveChance_sigPred = zeros(3, size(sesDict,2));

adjR2PWPI = zeros(1, size(sesDict,2));
pvalPWPI = zeros(1, size(sesDict,2));

adjR2PWPI_chance = zeros(1, size(sesDict,2));
pvalPWPI_chance = zeros(1, size(sesDict,2));

coeffPerSes = cell(3,length(sesDict));
coeffPerSes_sigPred = cell(length(sesDict),3);

numTrialsPerSes = zeros(1*numRepeats, size(sesDict,2));

countsStorage=zeros(3,length(sesDict));
countsIndStorage = zeros(3,length(sesDict),200);
countsCombinedStorage = zeros(3,length(sesDict),200);
percentagesCombinedStorage = zeros(3,length(sesDict),200);

sigPredStorage=zeros(128,3,12);
pvalStorage = zeros(128,3,12);
outlierStorage = zeros(4,12,200,10);
outlierStorageSigElec = zeros(4,12,200,10);
eligiblePredStorage = zeros(4,12,200,10);
noOutlierStorageSigElec = zeros(4,12,200,10);
betaStorage = [];
yTestPredStorage = [];

for s = sesOfInterest
    display({'session ' s})

    % isolate relevant trials
    sessionData = data(data.Session == s, :);
    phaseMeansPerSes = sessionData(:,4:end);
    conditions = sessionData.Condition;
    intensity = sessionData.NormalizedIntensity;

    % extract only SUPRATHRESHOLD conditions
    phaseMeansPerSes = phaseMeansPerSes(conditions > 4,:);
    intensity = intensity(conditions > 4);
    conditions = conditions(conditions > 4);
    
    % remove the trials that were not perceived
    conditions = conditions(intensity ~= 0);
    phaseMeansPerSes = phaseMeansPerSes(intensity ~= 0,:);
    intensity = intensity(intensity ~= 0);
    numTrials = size(conditions,1);
    numTrialsPerSes(s) = size(conditions,1);

    % convert phaseMeansPerSes
    phaseMeansPerSes = reshape(table2array(phaseMeansPerSes), numTrials, 5, 128);

    % initialize variables
    predictorsAll = [];
    predLabelsAll = [];

    %% do a simple linear regression between perceived intensity and PW
    % mdl = fitlm(intensity,conditions);
    % 
    % adjR2PWPI(s) = mdl.Rsquared.Adjusted;
    % pvalPWPI(s) = mdl.ModelFitVsNullModel.Pvalue;
    % 
    % k = numTrials;              % number of folds
    % cv = cvpartition(k, 'KFold', k);
    % 
    % for i = 1:k
    % 
    %     %% TRAIN / TEST SPLIT
    %     trainIdx = training(cv, i);
    %     testIdx  = test(cv, i);
    % 
    %     Xtrain = conditions(trainIdx);
    %     ytrain = intensity(trainIdx);
    % 
    %     Xtest = conditions(testIdx);
    %     ytest = intensity(testIdx);
    % 
    %     %% FIT OLS MODEL
    %     mdl = fitlm(Xtrain, ytrain);
    % 
    %     %% PREDICT ON TEST FOLD
    %     ypred = predict(mdl, Xtest);
    % 
    %     %% FOR LOOCV ONLY
    %     yPredStorage(i) = ypred;
    %     yTestStorage(i) = ytest;  
    % 
    % end
    % SSres2 = sum((yTestStorage - yPredStorage).^2);
    % SStot2 = sum((yTestStorage - mean(yTestStorage)).^2);
    % 
    % R22_PWPI(s) = 1 - SSres2/SStot2;

    %% SETTINGS
    k = numTrials;              % number of folds
    nRepeats = 1;      % number of repeated CV runs

    %% STORAGE
    R2_all = zeros(nRepeats, k);
    RMSE_all = zeros(nRepeats, k);
    AdjR2_all = zeros(nRepeats, k);
    yPredStorage = zeros(k,1);
    yTestStorage = zeros(k,1);
    R22 = zeros(nRepeats, 1);

    %% REPEATED CROSS-VALIDATION
    for r = 1:nRepeats
    
        % New random partition each repeat
        cv = cvpartition(numTrials, 'KFold', k);
    
        for i = 1:k
            display(i)
            %% TRAIN / TEST SPLIT
            trainIdx = training(cv, i);
            testIdx  = test(cv, i);

            % Standardize predictors using training data only
            trainMean = mean(phaseMeansPerSes(trainIdx,:,:), 1);
            trainStd = std(phaseMeansPerSes(trainIdx,:,:), 0, 1);
            trainStd(trainStd == 0 | isnan(trainStd)) = 1;
            phaseMeansPerSesNorm = (phaseMeansPerSes - trainMean) ./ trainStd;

            %% find the responsive electrodes in each epoch
            % do a simple linear regression between perceived intensity and PW

            for e = 1:128 % per electrode
                for epoch = 2:4 % per epoch
                    predictor = phaseMeansPerSesNorm(trainIdx,epoch,e); % Select predictors for the current epoch
                    
                    % see if the slope is significant
                    mdl = fitlm(predictor, intensity(trainIdx)); % Fit linear model for current electrode and epoch
                    pValue = coefTest(mdl); % Test the significance of the slope
                    
                    % see if the test data for each predictor is an
                    % outlier
                    testPt = phaseMeansPerSesNorm(testIdx,epoch,e);
                    numSTD=7;
                    outlier = testPt < (median(predictor) - numSTD*mad(predictor,1)) | testPt > (median(predictor) + numSTD*mad(predictor,1));

                    % mark the predictor that is bad
                    if outlier == 1
                        outlierStorage(epoch, s,i,r) = outlierStorage(epoch, s,i,r)+1;
                    end
                    
                    if pValue < 0.05 
                        eligiblePredStorage(epoch, s,i,r) = eligiblePredStorage(epoch, s,i,r)+1;
                        sigPredStorage(e,epoch-1,s) = 1;
                    end

                    if pValue < 0.05 && outlier == 0
                        pvalStorage(e,epoch-1,s) = pValue;
                        noOutlierStorageSigElec(epoch, s,i,r) = noOutlierStorageSigElec(epoch, s,i,r)+1;

                    end
                    if pValue < 0.05 && outlier ==1
                        outlierStorageSigElec(epoch, s,i,r) = outlierStorageSigElec(epoch, s,i,r)+1;
                    end
                end
            end
            
        elecOn = find(sigPredStorage(:,1,s)==1);
        elecSus = find(sigPredStorage(:,2,s)==1);
        elecOff = find(sigPredStorage(:,3,s)==1);
        % find the intersection of those electrodes
        elecAll = union(union(elecOn, elecSus),elecOff);
    
        for epoch = 1:4
        %%
            if epoch == 1
                predictors = squeeze(phaseMeansPerSesNorm(trainIdx,2,elecOn));
                predictorsTest = squeeze(phaseMeansPerSesNorm(testIdx,2,elecOn))';%'
            elseif epoch == 2
                predictors = squeeze(phaseMeansPerSesNorm(trainIdx,3,elecSus));
                predictorsTest = squeeze(phaseMeansPerSesNorm(testIdx,3,elecSus))';
            elseif epoch == 3
                predictors = squeeze(phaseMeansPerSesNorm(trainIdx,4,elecOff));
                predictorsTest = squeeze(phaseMeansPerSesNorm(testIdx,4,elecOff))';
            elseif epoch == 4
                predOn = squeeze(phaseMeansPerSesNorm(trainIdx,2,elecOn));
                predSus = squeeze(phaseMeansPerSesNorm(trainIdx,3,elecSus));
                predOff = squeeze(phaseMeansPerSesNorm(trainIdx,4,elecOff));
                predictorsTestOn = squeeze(phaseMeansPerSesNorm(testIdx,2,elecOn))';
                predictorsTestSus = squeeze(phaseMeansPerSesNorm(testIdx,3,elecSus))';
                predictorsTestOff = squeeze(phaseMeansPerSesNorm(testIdx,4,elecOff))';
                predictors = [predOn predSus predOff];
                predictorsTest = [predictorsTestOn predictorsTestSus predictorsTestOff];
                predLabels = [ones(size(predOn,2),1);ones(size(predSus,2),1)*2;ones(size(predOff,2),1)*3];
                [counts labels] = groupcounts(predLabels);
                countsStorage(labels,s) = counts;
            end
            
            numPred(epoch,s) = size(predictors, 2);
            
        
            %% determine which predictors to keep using LASSO regression
            k = numTrials;              % number of folds
            X = predictors;
            y = intensity(trainIdx);
    
            %% INNER CV: LASSO ON TRAINING DATA ONLY
            if isempty(X)
                ypred = mean(ytrain); 
                nullMdl(epoch, s) = nullMdl(epoch, s)+1;
            else
                [B, FitInfo] = lasso(X, y, 'CV', k-1);%k
                % Choose lambda
                idxLambda = FitInfo.Index1SE;
                predictorsToKeep = find(B(:,idxLambda)~=0);

                if isempty(predictorsToKeep)
                    nullMdl(epoch, s) = nullMdl(epoch, s)+1;
                end
                
                if epoch == 1
                    countsIndStorage(1,s,i,r) = length(predictorsToKeep);
                elseif epoch == 2
                    countsIndStorage(2,s,i,r) = length(predictorsToKeep);
                elseif epoch ==3
                    countsIndStorage(3,s,i,r) = length(predictorsToKeep);
                elseif epoch ==4
                    predLabelsToKeep = predLabels(predictorsToKeep);
                    [counts2 labels2] = groupcounts(predLabelsToKeep);
                    countsCombinedStorage(labels2,s,i,r) = counts2;
                    percentagesCombinedStorage(labels2,s,i,r) = counts2/sum(counts2);
                end

                predictors = predictors(:,predictorsToKeep);
                predictorsTest = predictorsTest(predictorsToKeep);
                if epoch == 1 || epoch == 2 || epoch == 3
                    predictorsAll = [predictorsAll predictors];
                    predLabelsAll = [predLabelsAll; ones(size(predictors,2),1)*epoch];
                end

                %% FIT OLS MODEL
                Xtrain = predictors;
                ytrain = intensity(trainIdx);

                Xtest = predictorsTest;
                ytest = intensity(testIdx);

                mdl = fitlm(Xtrain, ytrain);
                
                % store the beta coefficients and their p-values
                if epoch == 4
                    repeatNum = ones(size(predLabelsToKeep))*r;
                    session = ones(size(predLabelsToKeep))*s;
                    trial = ones(size(predLabelsToKeep))*i;
                    variables = [table(repeatNum) table(session) table(trial) table(predLabelsToKeep) mdl.Coefficients(2:end,'Estimate')  mdl.Coefficients(2:end,'pValue')];
                    variables.Properties.RowNames(:) = [];
                    betaStorage=[betaStorage; variables];
                end

                %% PREDICT ON TEST FOLD
                if isempty(Xtest)
                    ypred = mean(ytrain);  
                else
                    ypred = predict(mdl, Xtest);
                end
            end

            %% FOR LOOCV ONLY
            yPredStorage(i,epoch) = ypred;
            yTestStorage(i,epoch) = ytest; 
        end
    end

    %% FLATTEN RESULTS
    SSres2 = sum((yTestStorage - yPredStorage).^2);
    SStot2 = sum((yTestStorage - mean(yTestStorage)).^2);
   
    %% store the actual v. predicted values
    repeatNum = ones(numTrials,1)*r;
    session = ones(numTrials,1)*s;
    variables2 = [table(repeatNum) table(session) table(yTestStorage(:,1)) table(yPredStorage)];
    variables2.Properties.RowNames(:) = [];
    yTestPredStorage=[yTestPredStorage; variables2];

    for idx = 1:4
        r2(idx, s,r) = 1 - SSres2(idx)/SStot2(idx); 
    end
    end

%% for aggregation purposes
phaseAvgRespElecNorm = [phaseAvgRespElecNorm; phaseMeansPerSes];
cond = [cond; conditions];
int = [int; intensity];
end

%% create bar graph comparing the adjusted R2 values across sessions

averageR2=median(r2,3);

lavender = [190 145 178]/255;
figure
metric = averageR2;
sesToInclude = 1:10;
sesOn = sesToInclude;
sesSus =sesToInclude;
sesOff = sesToInclude;
sesAll =sesToInclude;
colors = [0 127 255; 255 194 51; 223 72 40;190 145 178]/255;

SetFont('Arial',12)
set(gcf, 'Units', 'inches', 'Position', [1 1 2 3])
hold on

% add dashed line at zero
yline(0,'Linestyle',"--",'Color',[125 125 125]/255)

Swarm(1,metric(1,sesOn),'Color',colors(1,:),'CenterMethod','Mean','DistributionStyle','Box') %[1:5, 9:11]

Swarm(2,metric(2,sesSus),'Color',colors(2,:),'CenterMethod','Mean','DistributionStyle','Box') %[5,9]

Swarm(3,metric(3,sesOff),'Color',colors(3,:),'CenterMethod','Mean','DistributionStyle','Box') %[3,12]

Swarm(4,metric(4,sesAll),'Color',lavender,'CenterMethod','Mean','DistributionStyle','Box') %[3,12]

% adjust the figure settings
xlim([0.5 4.5])
xticks([1:4])

xticklabels({'Onset', 'Sustained', 'Offset','Combined'})
ylabel('Predicted R2')

% do STATs using wilcoxon signed-rank test (non-parametric t-test)
% STATS to compare each group of slopes to adjusted R2 
zeroSlopeResults = zeros(1,4);
[zeroSlopeResults(1),~] = signrank(metric(1,sesOn),0);
[zeroSlopeResults(2),~] = signrank(metric(2,sesSus),0);
[zeroSlopeResults(3),~] = signrank(metric(3,sesOff),0);
[zeroSlopeResults(4),~] = signrank(metric(4,sesAll),0);

% resize the stats matrix to only use significant sessions
statsMetric = [metric(1,sesOn)' ones(length(metric(1,sesOn)),1)];
statsMetric = [statsMetric ; metric(2,sesSus)' 2*ones(length(metric(2,sesSus)),1)];
statsMetric = [statsMetric ; metric(3,sesOff)' 3*ones(length(metric(3,sesOff)),1)];
statsMetric = [statsMetric ; metric(4,sesAll)' 4*ones(length(metric(4,sesAll)),1)];

% do STATS using friedman's test
% [p,tbl,stats] = friedman(metric(:,sesToInclude)',1);
% postHocComparisons = multcompare(stats,'CriticalValueType','dunn-sidak');

% save figure
saveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'LinearRegression'];
titleString = 'PredictedR2AcrossEpochsMini_NoDataLeak';
saveFilenamejpg = [saveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

%% figure 8a-d: plot the actual v predicted plots
s=1;
r=1;

yTestPredValues=yTestPredStorage(yTestPredStorage.repeatNum==r & yTestPredStorage.session==s,:);
yTestPredValues = renamevars(yTestPredValues, "Var1", "Test");
colors = [0 127 255; 255 194 51; 223 72 40;190 145 178]/255;

for idx=4%1:4
    close all
    figure
    SetFont('Arial',12)
    set(gcf, 'Units', 'inches', 'Position', [1 1 2 2])
    hold on
    lav = [190 145 178]/255;
    darkLav = [51 30 46]/255;
    
    scatter(yTestPredValues.yPredStorage(:,idx),yTestPredValues.Test,'filled','MarkerFaceColor',colors(idx,:),'MarkerEdgeColor',colors(idx,:),'SizeData',20)
    % add black dashed line
    plot(-2:10,-2:10,'Color','k','LineStyle','--','LineWidth',2)
    
    ylim([-0.5 5.5])
    xlim([-0.5 5.5])
    xticks(0:5.5)
    yticks(0:5.5)
    
    xlabel('Predicted Intensity')
    ylabel('Actual Intensity')
    
    % save figure
    saveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'LinearRegression' filesep 'no data leakage'];
    titleString = ['Revised_PredActInt_7MAD_Ses' num2str(s) '_Epoch' num2str(idx) '_Rep' num2str(r)];
    saveFilenamejpg = [saveDir filesep char(titleString) '.jpg'];
    %exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)
end

%% figure 8f: beta coefficient weighting
% take the absolute value of all coefficients
betaStorage2=betaStorage;
betaStorage2.Estimate = abs(betaStorage2.Estimate);

betaSumStorage = zeros(nRepeats,12,300,3);

for r = 1%1:nRepeats
    for s = sesOfInterest
        for t = 1:numTrialsPerSes(s,1)
            % find the model that correspond to that session and trial
            modelBetas = betaStorage2(find(betaStorage2.repeatNum == r & betaStorage2.session == s & betaStorage2.trial == t),:);

            % take the sum of all predictors for that trial
            sumTotal = sum(modelBetas.Estimate);
    
            for pred = 1:3
                % find the average beta per epoch
                betaSumStorage(r,s,t,pred) = sum(modelBetas(find(modelBetas.predLabelsToKeep == pred),"Estimate")).Estimate/sumTotal;        
            end
        end
    end
end

avgBetaSumStorage = zeros(12,3);

% take the average across all trials
for s = sesOfInterest
    for pred = 1:3
        avgBetaSumStorage(s,pred) = mean(betaSumStorage(2,s,1:numTrialsPerSes(s,1),pred));
    end
end

colors = [0 127 255; 255 194 51; 223 72 40;190 145 178]/255;
figure
SetFont('Arial',12)
set(gcf, 'Units', 'inches', 'Position', [1 1 2 2.3])
hold on
for pred = 1:3
    betaValues = avgBetaSumStorage([1:10],pred);
    Swarm(pred,betaValues*100,'Color',colors(4,:),'CenterMethod','Mean','DistributionStyle','Box','SwarmPointLimit',10000);
end

xticks(1:3)
xticklabels({'Onset','Sustained','Offset'})
ylabel('Relative Contribution (%)')
xlim([0.5 3.5])

% stats
% [p,tbl,stats] = friedman(avgBetaSumStorage([1:10],:),1);
% postHoc = multcompare(stats,'CriticalValueType','dunn-sidak');

% save figure
saveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'LinearRegression' filesep 'wout best fit line & LOOCV feature sel' ];
titleString = 'BetaPartialContribution';
saveFilenamejpg = [saveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)
