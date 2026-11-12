%% Figure 7 Script
close all; clear; clc;

%% USER INPUT NEEDED %%
dataDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Manuscripts' filesep 'PW Manuscript'];
saveDir = [filesep  'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'PNS Prox Dist Comparison' filesep 'percentCoverage' filesep 'manuscript 1 coverage'];
%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
data = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 7_1');
avgData = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 7_2');
heatmapData = readtable([dataDir filesep 'SourceData.xlsx'], 'Sheet', 'Fig 7_3');

totalCoM1 = [data.CoM1_x data.CoM1_y];
totalCoM2 = [data.CoM2_x data.CoM2_y];
totalCond = data.ConditionNumber;
totalContacts = data.Contact;
totalSesNum = data.Session;
sesOfInterest = 1:10;
sesDict = 1:10;
condMeanCoM1Excitatory = reshape([avgData.CoM1_x avgData.CoM1_y],2,10,10);
condMeanCoM2Excitatory = reshape([avgData.CoM2_x avgData.CoM2_y],2,10,10);

%% figure 7a
for condition = 1:10
    % find relevant rows
    condData=heatmapData(heatmapData.Condition==condition,2:end);
    condData=table2array(condData);
    % for median example session
    array1_peak = reshape(condData(:,1),[8,8]);
    array1_peak = array1_peak.'; 
    array1_peak = flip(array1_peak,2);
    array2_peak = reshape(condData(:,2),[8,8]);
    array2_peak = array2_peak.'; 
    array2_peak = flip(array2_peak,2);
 
    FRHeatmapGen(array1_peak,array2_peak,"ElecOnsetBehavior "+string(condition)+" "+"MedianExample","",saveDir)

    % for ulnar example session
    array1_peak = reshape(condData(:,3),[8,8]);
    array1_peak = array1_peak.'; 
    array1_peak = flip(array1_peak,2);
    array2_peak = reshape(condData(:,4),[8,8]);
    array2_peak = array2_peak.'; 
    array2_peak = flip(array2_peak,2);
 
    FRHeatmapGen(array1_peak,array2_peak,"ElecOnsetBehavior "+string(condition)+" "+"UlnarExample","",saveDir)

end

%% figure 7e: plot centroid of median and ulnar on array 2
% the sessions can be combined within PNS input
% median = [187 204 238]/255;
% ulnar = [255 204 204]/255;

% darker point colors
median = [124 157 222]/255;%[187 204 238]/255;
ulnar = [255 133 133]/255;%[255 204 204]/255;

% find the centroid of all median and ulnar points
medianCoM2 = nanmean(totalCoM2(totalCond>4 & (totalContacts==1 | totalContacts==2),:),1);
ulnarCoM2 = nanmean(totalCoM2(totalCond>4 & (totalContacts==4 | totalContacts==5),:),1);

figure
hold on
a = scatter(totalCoM2(totalCond>4 & (totalContacts==1 | totalContacts==2),1),totalCoM2(totalCond>4 & (totalContacts==1 | totalContacts==2),2),70,'filled','MarkerFaceColor',median);
b = scatter(totalCoM2(totalCond>4 & (totalContacts==4 | totalContacts==5),1),totalCoM2(totalCond>4 & (totalContacts==4 | totalContacts==5),2),70,'filled','MarkerFaceColor',ulnar);

% xc = nanmean(totalCoM2(totalCond>4,:));
% quiver(xc(1), xc(2), coeff2(1, 1), coeff2(2, 1), 'k' , 'DisplayName', 'Principal','LineWidth',2,'MaxHeadSize',.75);
% quiver(xc(1), xc(2), -coeff2(1, 1), -coeff2(2, 1), 'k','HandleVisibility','off','LineWidth',2,'MaxHeadSize',.75);

scatter(medianCoM2(1),medianCoM2(2),150,'filled','MarkerFaceColor','#7C9DDE','MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
scatter(ulnarCoM2(1),ulnarCoM2(2),150,'filled','MarkerFaceColor','#FF8585','MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
% Eigenvectors as arrows from data mean
% quiver(mu2(1)*ones(1,2), mu2(2)*ones(1,2), coeff2(1,:), coeff2(2,:), 0.5, 'k');
% quiver(mu2(1),mu2(2),coeff2(1,1), coeff2(1,2), 0.5, 'k');
legend({'Median PNS','Ulnar PNS','Trial-Averaged Median Weighted Centroid','Trial-Averaged Ulnar Weighted Centroid'},'Location','southoutside')
xlim([0 8])
xticks([0:1:8])
ylim([0 8])
yticks([0:1:8])
set(gca,'Yticklabel',[]) 
set(gca,'Xticklabel',[]) %to just get rid of the numbers but leave the ticks.
%set(gca, 'XColor','white')
axis square
grid on
box on
set(gca, 'LineWidth',2)
set(a, 'MarkerFaceAlpha', 0.3) % set transparency level
set(b, 'MarkerFaceAlpha', 0.3) % set transparency level

set(gca,'FontSize',16)
set(gca,'Color','w');

% save figure
plotSaveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'Centroids'];
titleString = 'CompiledWeightedCentroidMedianUlnar';
saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

%% show the PCA projection of points 
[coeff1,score1,latent1,tsquared1,explained1,mu1] = pca(totalCoM1(totalCond>4,:));
[coeff2,score2,latent2,tsquared2,explained2,mu2] = pca(totalCoM2(totalCond>4,:));
condFiltered = totalCond(totalCond>4); 
contactFiltered = totalContacts(totalCond>4);
sesFiltered = totalSesNum(totalCond>4);

%% MANUCSRIPT 1 PCA figure: labeled as median or ulnar 

median = [124 157 222]/255;
ulnar = [255 133 133]/255;

figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 2.8 2.2])

hold on
edges = linspace(-3.2, 3.2, 50); % Create 100 bins.
% Plot the histogram.
histogram(score2(contactFiltered==1 | contactFiltered==2,1), 'BinEdges',edges, 'FaceColor', median,'EdgeColor','none');
histogram(score2(contactFiltered==4 | contactFiltered==5,1), 'BinEdges',edges, 'FaceColor', ulnar,'EdgeColor','none');

xlabel('PC1')
ylabel(["Centroid Count"])
%set(gca,'FontSize',50)
set(gca,'Color','w');
%set(gca,'LineWidth',2.5);

% % save figure
plotSaveDir = [filesep 'Users' filesep 'preethisiribhat'  filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'Centroids'];
titleString = 'ProjectionMedianUlnarPC1';
saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

%% MANUCSRIPT 1 PCA figure: between PNS inputs
m1 = [15,181,174]/255; % teal
m2 = [64,70,202]/255; % purple
u4 = [246,133,17]/255; % orange
u5 = [222,61,130]/255; % pink

figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 2.8 2.2])

hold on
edges = linspace(-3.2, 3.2, 50); % Create 100 bins.
% Plot the histogram.
histogram(score2(contactFiltered==1,1), 'BinEdges',edges, 'FaceColor', m1,'EdgeColor','none');
histogram(score2(contactFiltered==2,1), 'BinEdges',edges, 'FaceColor', m2,'EdgeColor','none');
% histogram(score2(contactFiltered==4,1), 'BinEdges',edges, 'FaceColor', u4,'EdgeColor','none');
% histogram(score2(contactFiltered==5,1), 'BinEdges',edges, 'FaceColor', u5,'EdgeColor','none');

xlabel('PC1')
ylabel(["Centroid Count"])
ylim([0 30])
%yticks([0 15 30])
%set(gca,'FontSize',50)
set(gca,'Color','w');
%set(gca,'LineWidth',2.5);

% save figure
plotSaveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'Centroids'];
titleString = 'ProjectionMedianContactsPC1';
saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

%% compiled fig: plot centroid of EACH PNS INPUT on array 2
% the sessions can be combined within PNS input
m1 = [15,181,174]/255; % teal
m2 = [64,70,202]/255; % purple
u4 = [246,133,17]/255; % orange
u5 = [222,61,130]/255; % pink

% find the centroid of each PNS input
m1CoM2 = nanmean(totalCoM2(totalCond>4 & totalContacts==1,:),1);
m2CoM2 = nanmean(totalCoM2(totalCond>4 & totalContacts==2,:),1);
u4CoM2 = nanmean(totalCoM2(totalCond>4 & totalContacts==4,:),1);
u5CoM2 = nanmean(totalCoM2(totalCond>4 & totalContacts==5,:),1);

figure
hold on
a = scatter(totalCoM2(totalCond>4 & totalContacts==1,1),totalCoM2(totalCond>4 & totalContacts==1,2),70,'filled','MarkerFaceColor',m1);
b = scatter(totalCoM2(totalCond>4 & totalContacts==2,1),totalCoM2(totalCond>4 & totalContacts==2,2),70,'filled','MarkerFaceColor',m2);
c = scatter(totalCoM2(totalCond>4 & totalContacts==4,1),totalCoM2(totalCond>4 & totalContacts==4,2),70,'filled','MarkerFaceColor',u4);
d = scatter(totalCoM2(totalCond>4 & totalContacts==5,1),totalCoM2(totalCond>4 & totalContacts==5,2),70,'filled','MarkerFaceColor',u5);
% 
xc = nanmean(totalCoM2(totalCond>4,:));
quiver(xc(1), xc(2), coeff2(1, 1), coeff2(2, 1), 'k' , 'DisplayName', 'Principal','LineWidth',2,'MaxHeadSize',.75);
quiver(xc(1), xc(2), -coeff2(1, 1), -coeff2(2, 1), 'k','HandleVisibility','off','LineWidth',2,'MaxHeadSize',.75);

scatter(m1CoM2(1),m1CoM2(2),150,'filled','MarkerFaceColor',m1,'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
scatter(m2CoM2(1),m2CoM2(2),150,'filled','MarkerFaceColor',m2,'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
scatter(u4CoM2(1),u4CoM2(2),150,'filled','MarkerFaceColor',u4,'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)
scatter(u5CoM2(1),u5CoM2(2),150,'filled','MarkerFaceColor',u5,'MarkerEdgeColor','k','MarkerFaceAlpha',1,'LineWidth',2)

for i = [a,b,c,d]
    set(i, 'MarkerFaceAlpha', 0.3) % set transparency level
end

xlim([0 8])
xticks([0:1:8])
ylim([0 8])
yticks([0:1:8])
set(gca,'Yticklabel',[]) 
set(gca,'Xticklabel',[]) %to just get rid of the numbers but leave the ticks.
%set(gca, 'XColor','white')
axis square
grid on
box on
set(gca, 'LineWidth',2)
set(gca,'FontSize',16)
set(gca,'Color','w');

% save figure
plotSaveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'Centroids'];
titleString = 'CompiledWeightedCentroidPNSInputs';
saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

%% compiling euclidean distance of 2D spread

totalEuclidDistStd1 = [];
totalEuclidDistStd2 = [];

for s = sesOfInterest % number of sessions
    % acquire variables for given session
    sessionData=data(data.Session==s,:);
    CoM1Ses = [sessionData.CoM1_x sessionData.CoM1_y];
    CoM2Ses = [sessionData.CoM2_x sessionData.CoM2_y];
    condSes = sessionData.ConditionNumber; 
    EuclidDistStd1 = zeros(length(condSes),1);EuclidDistStd2 = zeros(length(condSes),1);

    for c = 1:10
        % find the trials that correspond to the condition
        trials4Cond = find(condSes==c);
        for t = 1:length(trials4Cond)
            % calculate the euclidean distance btwn com for trial to avg
            % weighted centroid
            EuclidDistStd1(trials4Cond(t)) = pdist([CoM1Ses(trials4Cond(t,:),:);condMeanCoM1Excitatory(:,c,s)'],'euclidean');
            EuclidDistStd2(trials4Cond(t)) = pdist([CoM2Ses(trials4Cond(t,:),:);condMeanCoM2Excitatory(:,c,s)'],'euclidean');
        end
    end
    totalEuclidDistStd1 = [totalEuclidDistStd1; EuclidDistStd1];
    totalEuclidDistStd2 = [totalEuclidDistStd2; EuclidDistStd2];
end

%% linear regression plot 
% gray lines on plot, not much to be said 
metric = totalEuclidDistStd2;
figure
SetFont('Arial', 12)
set(gcf, 'Units', 'inches', 'Position', [1 1 2.7 2.2])

hold on
for j = sesOfInterest  % [1,2,3,5,9] % number of sessions we are analyzin
    %find slope of suprathreshold conditions
    mdl=fitlm(totalCond(totalCond>4 & totalSesNum == sesDict(j)),metric(totalCond>4 & totalSesNum == sesDict(j)));
    slope = table2array(mdl.Coefficients(2,1));
    intercept = table2array(mdl.Coefficients(1,1));
    x = 5:10;
    y = intercept + slope*x;
    if ismember(j,[1 3 5 9]) == 1
        plot(x,y,'Color', '#BE91B2','LineStyle','-') %'LineWidth', 5,'#BE91B2','LineStyle','-'
    else
        plot(x,y,'Color', '#000000','LineStyle',':') %'LineWidth', 4,'#A3A3A3','LineStyle',':
    end
end

% trialsSubset = metric(totalCond>4 & (totalSesNum ==4 | totalSesNum ==6 |totalSesNum ==8 |totalSesNum ==12));
% condSubset = totalCond(totalCond>4 & (totalSesNum ==4 | totalSesNum ==6 |totalSesNum ==8 |totalSesNum ==12));
% sesSubset = totalSesNum(totalCond>4 & (totalSesNum ==4 | totalSesNum ==6 |totalSesNum ==8 |totalSesNum ==12));
% 
% mdl=fitlm(condSubset,trialsSubset);
% slope = table2array(mdl.Coefficients(2,1));
% intercept = table2array(mdl.Coefficients(1,1));
% x = 4:11;
% y = intercept + slope*x;
%plot(x,y,'Color', '#A46593','LineWidth', 6)
ylabel('Centroid Variance')
ylim([0 1.6])
xlim([5 10])
xticks([5:10])
xticklabels({"0", "20", "40", "60", "80", "100"})
xtickangle(0)
xlabel('PW Condition (%)')
%legend({'Sessions with slope p-value < 0.05','','','Sessions with slope p-value > 0.05', '','','','',''},'Location','southoutside','FontSize',18)
%legend({'Sessions with slope p-value < 0.05','','','Sessions with slope p-value > 0.05', '','','','','','Average of sessions with significant slope'},'Location','southoutside','FontSize',18)

%legend('boxoff')
%set(gca,'FontSize',25)
set(gca,'Color','w');
%set(gca, 'LineWidth',2.5)

% save figure
plotSaveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'Centroids'];
titleString = 'CentroidStdTrendAllSesUpdatedColors';
saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)

%% showing a small example of centroid variance
m1 = "#0FB5AE"; % teal
m2 = "#4046CA"; % purple
u4 = "#F68511"; % orange
u5 = "#DE3D82"; % pink
colorSet = [m2 m2 m1 m1 m1 u5 u5 u5 u5 u4 u4 u5 ];
colorSet = ["#000000"];
headWidth = 20;
headLength = 10;
LineLength = .9;

figure()
hold on
for s = 1%[1,2,3,5,9]%[1:5,9:12] % number of sessions
    sessionData=data(data.Session==s,:);
    CoM2PerTrial = [sessionData.CoM2_x sessionData.CoM2_y];
    condSes = sessionData.ConditionNumber;
    
    for c = 5
        a = scatter(CoM2PerTrial(condSes==c,1),CoM2PerTrial(condSes==c,2),300,'filled','MarkerFaceColor',colorSet(s));
        xlim([0 8])
        ylim([0 8])
        axis square
        grid on
        set(a, 'MarkerFaceAlpha', 0.3) % set transparency level

        % calculate euclidean distance btwn points and avg centroid
        directionalVec=[CoM2PerTrial(condSes==c,1),CoM2PerTrial(condSes==c,2)]-[condMeanCoM2Excitatory(1,c,s),condMeanCoM2Excitatory(2,c,s)];
        for t = 1:length(CoM2PerTrial(condSes==c,1))
            q = quiver(condMeanCoM2Excitatory(1,c,s),condMeanCoM2Excitatory(2,c,s),directionalVec(t,1),directionalVec(t,2),'Color',[1 1 1],'LineWidth',1,'MaxHeadSize',1);
            
            %get the data from regular quiver
            U = q.UData;
            V = q.VData;
            X = q.XData;
            Y = q.YData;
            
            hold on;
            for ii = 1:length(X)
                for ij = 1:length(X)
            
                    headWidth = 5;
                    ah = annotation('arrow',...
                        'headStyle','cback1','HeadLength',headLength,'HeadWidth',headWidth);
                    set(ah,'parent',gca);
                    set(ah,'position',[X(ii,ij) Y(ii,ij) LineLength*U(ii,ij) LineLength*V(ii,ij)]);
            
                end
            end
        end
        b = scatter(condMeanCoM2Excitatory(1,c,s),condMeanCoM2Excitatory(2,c,s),900,'filled','MarkerFaceColor',colorSet(s),'MarkerEdgeColor','k');
        set(b, 'MarkerFaceAlpha', 1) % set transparency level

    end
end

xlim([0 8])
xticks([0:1:8])
ylim([0 8])
yticks([0:1:8])
set(gca,'Yticklabel',[]) 
set(gca,'Xticklabel',[]) %to just get rid of the numbers but leave the ticks.
%set(gca, 'XColor','white')
axis square
grid on
box on
set(gca, 'LineWidth',3)

set(gca,'FontSize',16)
set(gca,'Color','w');

% save figure
plotSaveDir = [filesep 'Users' filesep 'preethisiribhat' filesep 'Box Sync' filesep 'Graczyk Lab - Bhat' filesep 'Data' filesep 'Manuscript1_Analysis' filesep 'Centroids'];
titleString = 'ExampleCentroidVariance';
saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
%exportgraphics(gcf,saveFilenamejpg,'Resolution',1200)
