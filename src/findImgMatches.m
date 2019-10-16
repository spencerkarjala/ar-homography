%% PURPOSE:  Extract features, obtain their descriptors, and match them!
%  INPUTS:   I1, I2 are images to match
%  OUTPUTS:  locs1, locs2 are Nx2 matrices with (x,y) for matched pairs
function [pts1, pts2] = findImgMatches(I1, I2)

    %% Convert images to grayscale, if necessary
    if (ndims(I1) == 3)
        I1 = rgb2gray(I1);
    end
    if (ndims(I2) == 3)
        I2 = rgb2gray(I2);
    end
    
    %% Detect features in both images
    
    % Use FAST for feature detection
    corners1 = detectFASTFeatures(I1);
    corners2 = detectFASTFeatures(I2);
    
    % Get the location of the strongest-magnitude features
    pts1 = corners1.Location;
    pts2 = corners2.Location;
    
    %% Obtain descriptors for the computed feature locations
    % Use BRIEF to create descriptors for each detected feature
    [desc1, pts1] = calcBriefDesc(I1, pts1);
    [desc2, pts2] = calcBriefDesc(I2, pts2);

    %% Match features using the descriptors
    indices = matchFeatures(desc1, desc2, 'MatchThreshold', 10.0, 'MaxRatio', 0.75);
    
    % Get the locations of the matched features
    pts1 = pts1(indices(:, 1), :);
    pts2 = pts2(indices(:, 2), :);
end