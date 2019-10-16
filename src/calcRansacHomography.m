%% PURPOSE: Compute the best-fitting homography from a list of matches
%  INPUT:   locs1, locs2 are two lists of matching points
%  OUTPUT:  bestH2to1 is the best-fitting homography for locs1 & locs2,
%           and inliers is a matrix of the inliers found during RANSAC
function [bestH21, inliers] = calcRansacHomography(pts1, pts2)

    % Initialize the number of RANSAC iterations to run and the maximum
    % distance for which to accept inliers
    N = 300;
    DISTANCE_MAX = 3;
    
    % Find the number of keypoints being checked
    numKeypoints = size(pts1,1);
    
    % Set the random sample size
    samples = 4;
    
    % Initialize best homography matrix and best set of inliers
    bestH21 = zeros(3,3);
    inliers   = zeros(size(pts1,1),1);
    
    % Use RANSAC to compute the best homography and the best inlier set
    for i = 1 : N
        % Determine randomly which keypoints to use
        currKeys = ceil(numKeypoints * rand(1,samples))';
        
        currLocs1 = pts1(currKeys(:,1), :);
        currLocs2 = pts2(currKeys(:,1), :);
        
        % If any keypoint was chosen more than once, skip iteration
        if numel(unique(currKeys))  ~= samples || ...
           numel(unique(currLocs1)) ~= samples*2 || ...
           numel(unique(currLocs2)) ~= samples*2
            continue;
        end
        
        % Calculate the locs2->locs1 homography with normalized coords
        H = calcNormHomography(pts1(currKeys(:,1),:), ...
                               pts2(currKeys(:,1),:));
        
        if det(H) < 1e-5
            continue;
        end
        
        % Calculate a second set of points with H
        locs1_m = H * [pts2, ones(size(pts2,1), 1)]';
        locs2_m = H \ [pts1, ones(size(pts1,1), 1)]';
        
        % Scale them so the homogeneous extension w is 1
        locs1_m = (locs1_m(1:2,:) ./ locs1_m(3,:))';
        locs2_m = (locs2_m(1:2,:) ./ locs2_m(3,:))';
        
        % Calculate the distance from the original keypoint locations to
        % the keypoint locations found from the mappings
        distance = sqrt((pts1(:,1) - locs1_m(:,1)).^2 ...
                 +      (pts1(:,2) - locs1_m(:,2)).^2)...
                 + sqrt((pts2(:,1) - locs2_m(:,1)).^2 ...
                 +      (pts2(:,2) - locs2_m(:,2)).^2);
        
        % Determine which points were inliers for this homography
        currIn = distance < DISTANCE_MAX;
        
        % Count the current and max number of inliers
        currNumIn = sum(currIn(:) == 1);
        currMaxIn = sum(inliers(:) == 1);
        
        % Determine if the number of inliers is greater than the current 
        % max or if they are equal and current standard deviation is less
        % than the current min standard deviation
        isBestResult = currMaxIn < currNumIn;

        % If the above condition is met, set the best homography to be the
        % current homography and the best inliers to be the current set
        bestH21 = bestH21 .* ~isBestResult + H .* isBestResult;
        inliers   = inliers .* ~isBestResult + currIn.* isBestResult;
    end
    
    % Remove any keypoints that do not correspond to inliers from above
    locs1In = pts1 .* inliers;
    locs1In(~any(locs1In,2),:) = [];
    locs2In = pts2 .* inliers;
    locs2In(~any(locs2In,2),:) = [];

    % Recompute the homography based off the inliers
    bestH21 = calcNormHomography(locs1In, locs2In);
    bestH21 = bestH21 ./ bestH21(3,3);
end