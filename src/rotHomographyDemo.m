% Clear the workspace and command window
clc;
clear;

% Set equal to 'BRIEF' or 'SURF'
mode = 'BRIEF';

%% Read the image and convert to grayscale, if necessary
Im = imread('../res/cv_cover.jpg');
if (ndims(Im) == 3)
    Im = rgb2gray(Im);
end

%% Compute the features and descriptors
if strcmp(mode, 'BRIEF')
    % Find feature points present in the original image using FAST
    cornersOrg = detectFASTFeatures(Im);
    locsOrg    = cornersOrg.Location;
    
    % Extract original image feature descriptors using BRIEF
    [featsOrg, locsOrg] = calcBriefDesc(Im, locsOrg);
    
elseif strcmp(mode, 'SURF')
    % Find feature points present in the original image using SURF
    pointsOrg = detectSURFFeatures(Im);
    
    % Extract original image feature descriptors using SURF
    [featsOrg, locsOrg] = extractFeatures(Im, pointsOrg, 'Method', 'SURF');
end

% Initialize the number of matches for the rotated images to the original
numMatches = 0;

%% Compute the features and descriptors for each rotated image
for i = 0:36
    % Rotate the original image
    imRot = imrotate(Im, 10 * i, 'bilinear', 'loose');
    
    if strcmp(mode, 'BRIEF')
        % Find feature points present in the rotated image using FAST
        cornersRot = detectFASTFeatures(imRot);
        locsRot    = cornersRot.Location;
        
        % Extract rotated image feature descriptors using BRIEF
        [featsRot, locsRot] = calcBriefDesc(imRot, locsRot);    

        % Match features of rotated image with original image
        matchIndices = matchFeatures(featsOrg, featsRot, 'MatchThreshold', 10.0, 'MaxRatio', 0.75);
        
    elseif strcmp(mode, 'SURF')
        % Find feature points present in the rotated image using SURF
        pointsRot = detectSURFFeatures(imRot);
        
        % Extract rotated image feature descriptors using SURF
        [featsRot, locsRot] = extractFeatures(imRot, pointsRot, 'Method', 'SURF');
        
        % Match features of rotated image with original image
        matchIndices   = matchFeatures(featsOrg, featsRot);
    end
    
    % Obtain locations of matched features between images
    locsOrgResult = locsOrg(matchIndices(:,1), :);
    locsRotResult = locsRot(matchIndices(:,2), :);
    
    % Add current features to the running count for histogram
    numMatches = [numMatches, 10*i * ones(1,size(matchIndices,1))];
end

%% Display histogram
% Remove the initial 0 from the match counter
numMatches = numMatches(1,2:size(numMatches,2));

figure(4);
hold on;
% Create a histogram for the matches with proper axis labels
h = histogram(numMatches);
h.BinEdges = -5:10:365;
xlabel('Angle of Rotation (Degrees)', 'fontsize', 14);
ylabel('Number of Matches', 'fontsize', 14);
title('Fig. 2: Number of Feature Matches for a Rotated Image Using SURF', 'fontsize', 20);
hold off;