% Script to read in locations of interest, select appropriate quadrant
% masks, and create a composite image of the hand

% Author: Preethisiri Bhat (pxb399@case.edu)
% Adapted from PlotByConditionPANorm.m written by Leah Marie Roldan
function plotQuarterLocFreq(maskFrequency,shade)
% Mask frequency stands for a table of the number of times each mask is
% called during the experiment
% Labels the region of the hand with intensity corresponding to percentage
% reported
%close all;

%% Load the masks library
load('quarterRegionMaskLibrary.mat');

%% Load and create full hand image picture
templateImage = rgb2gray(imread('Multimodal Hand Details.png')); % Ventral right hand

figure
imshow(templateImage,'Parent',gca);
hold(gca,'on')

% Get dimensions to plot and make mat matrix
szxP = size(templateImage,1);
szyP = size(templateImage,2);
matP = zeros(szxP,szyP);

% Set up color vectors for image
colorvec = shade;

for i = 1:length(maskFrequency)
    maskLabel = maskFrequency{i,1};
    freqReported = maskFrequency{i,2};
    if ~contains( maskLabel , "VA" ) && ~contains(  maskLabel , "No locations reported" )  && ~contains( maskLabel , "DA" ) 
        mask = getfield(masks,maskLabel).* freqReported;
        matP = matP + mask; 
    end
end

if any(any(matP))
        %matP = normalizeMat(matP);
        layer1P = colorvec(1)*ones(szxP,szyP);
        layer2P = colorvec(2)*ones(szxP,szyP);
        layer3P = colorvec(3)*ones(szxP,szyP);
        colorim = cat(3,layer1P,layer2P,layer3P);

        alphadatP = matP;
        image(colorim,'AlphaData',alphadatP)
        %title(ttl,'FontSize',15);
        %xlabel({xlab1;xlab2})
end
% have to manually save the image
end