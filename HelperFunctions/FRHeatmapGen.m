function FRHeatmapGen(array1,array2,feature,cond,plotSaveDir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
close all;
load('vik.mat');
% Got array1_peak and array2_peak from reshape(peak(65:128),[8,8])

xval1 = {'64','63','62','61','60','59','58','57'};
yval1 = {'8','16','24','32','40','48','56','64'};
f1 = figure();

colorbar = [vik(4:4:128,:);vik(128:256,:)];

%'ColorLimits',[-35 35]
h1 = heatmap(xval1,yval1,array1,'Colormap',colorbar,'ColorLimits',[-10 40],'CellLabelColor','none');
grid on
%colorbar off
h1.Title = 'Normalized Firing Rate';
h1.XLabel = 'Electrode (1-64)';

set(gca,'FontSize', 14)
set(gcf,'color','w')

% https://www.mathworks.com/matlabcentral/answers/481666-heatmap-chart-depict-squares-rather-than-rectangles
% Temporarily change axis units 
originalUnits = h1.Units;  % save original units (probaly normalized)
h1.Units = 'centimeters';  % any unit that will result in squares
% Get number of rows & columns
sz = size(h1.ColorData); 
% Change axis size & position;
originalPos = h1.Position; 
% make axes square (not the table cells, just the axes)
h1.Position(3:4) = min(h1.Position(3:4))*[1,1]; 
if sz(1)>sz(2)
    % make the axis size more narrow and re-center
    h1.Position(3) = h1.Position(3)*(sz(2)/sz(1)); 
    h1.Position(1) = (originalPos(1)+originalPos(3)/2)-(h1.Position(3)/2);
else
    % make the axis size shorter and re-center
    h1.Position(4) = h1.Position(4)*(sz(1)/sz(2));
    h1.Position(2) = (originalPos(2)+originalPos(4)/2)-(h1.Position(4)/2);
end
% Return axis to original units
h1.Units = originalUnits;

% Save the figure
% titleString = strcat("Array1 ", feature);%, " - ",cond);
% title(titleString);
% saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
% saveas(gcf,saveFilenamejpg);

%%%

xval2 = {'128','127','126','125','124','123','122','121'};
yval2 = {'72','80','88','96','104','112','120','128'};

f2 = figure();

%'ColorLimits',[-35 35],
%h2 = heatmap(xval2,yval2,array2,'Colormap',parula,'ColorLimits',[0 1],'CellLabelColor','none');
h2 = heatmap(xval2,yval2,array2,'Colormap',colorbar,'ColorLimits',[-10 40],'CellLabelColor','none');

grid on
%colorbar off
h2.Title = 'Normalized Firing Rate';
h2.XLabel = 'Electrode (65-128)';

set(gca,'FontSize', 14)
set(gcf,'color','w')

% Temporarily change axis units 
originalUnits = h2.Units;  % save original units (probaly normalized)
h2.Units = 'centimeters';  % any unit that will result in squares
% Get number of rows & columns
sz = size(h2.ColorData); 
% Change axis size & position;
originalPos = h2.Position; 
% make axes square (not the table cells, just the axes)
h2.Position(3:4) = min(h2.Position(3:4))*[1,1]; 
if sz(1)>sz(2)
    % make the axis size more narrow and re-center
    h2.Position(3) = h2.Position(3)*(sz(2)/sz(1)); 
    h2.Position(1) = (originalPos(1)+originalPos(3)/2)-(h2.Position(3)/2);
else
    % make the axis size shorter and re-center
    h2.Position(4) = h2.Position(4)*(sz(1)/sz(2));
    h2.Position(2) = (originalPos(2)+originalPos(4)/2)-(h2.Position(4)/2);
end
% Return axis to original units
h2.Units = originalUnits;

% Save the figure
% titleString = strcat("Array2 ",feature);%, " - ",cond);
% title(titleString);
% saveFilenamejpg = [plotSaveDir filesep char(titleString) '.jpg'];
% saveas(gcf,saveFilenamejpg);
end

