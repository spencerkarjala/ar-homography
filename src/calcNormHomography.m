%% PURPOSE: Normalizes point sets and calculates homography from x2 => x1
%  INPUT:   x1, x2 are sets of points
%  OUTPUT:  The homography H from x2 to x1
function [H21] = calcNormHomography(x1, x2)

    %% Compute centroids of the points
    % Calculate the mean value of (x,y) for both point sets
    centroid1 = [mean(x1(:,1)), mean(x1(:,2))];
    centroid2 = [mean(x2(:,1)), mean(x2(:,2))];

    %% Shift the origin of the points to the centroid
    % Subtract the mean (x,y) value from both point sets
    x1n = x1 - ones(size(x1)) .* centroid1;
    x2n = x2 - ones(size(x2)) .* centroid2;

    %% Calculate the distance used to scale points to distance sqrt(2)
    % Calculate the mean distance from the origin for both point sets
    meanDistance1 = mean(sqrt(x1n(:,1).^2 + x1n(:,2).^2));
    meanDistance2 = mean(sqrt(x2n(:,1).^2 + x2n(:,2).^2));
    
    %% similarity transform 1
    % Transform to put centroid at origin and scale to average distance of
    % sqrt(2) from the origin for first set of points
    T1 = (sqrt(2) / meanDistance1) .* [1, 0, -centroid1(1); 
                                       0, 1, -centroid1(2);
                                       0, 0, meanDistance1 / sqrt(2)];
    

    %% similarity transform 2
    % Transform to put centroid at origin and scale to average distance of
    % sqrt(2) from the origin for first set of points
    T2 = (sqrt(2) / meanDistance2) .* [1, 0, -centroid2(1); 
                                       0, 1, -centroid2(2);
                                       0, 0, meanDistance2 / sqrt(2)];
      
    %% Translate and scale points according to similarity transforms
    x1n = T1 * [x1, ones(size(x1,1), 1)]';
    x2n = T2 * [x2, ones(size(x2,1), 1)]';
    
    %% Compute Homography
    % Use the normalized values to obtain a homography from x2 to x1
    H = calcHomography(x1n(1:2,:)', x2n(1:2,:)');

    %% Denormalization
    % Compute the denormalized homography using the similarity transforms
    H21 = T1 \ H * T2;
end
