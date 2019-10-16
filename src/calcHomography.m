%% PURPOSE: Computes the homography from points 'x2' to points 'x1'
%  INPUT:   x1, x2 are sets of points
%  OUTPUT:  The homography H from x2 to x1
function H = calcHomography( x1, x2 )

    % Convert the input coordinates into homogeneous coordinates
    x1 = [x1, ones(size(x1,1), 1)];
    x2 = [x2, ones(size(x2,1), 1)];
    
    % Initialize the matrix of homogeneous equations to 0
    A = zeros(2 * size(x1,1), 9);
    
    % Add the homogeneous equations to the matrix A
    for i = 1 : size(x1,1)
        A(2*i-1, :) = [-1 * x2(i,:), zeros(1,3), x1(i,1) .* x2(i,:)];
        A(2*i, :)   = [zeros(1,3), -1 * x2(i,:), x1(i,2) .* x2(i,:)];
    end
    
    % Calculate the singular value decomposition of the homgeneous
    % equations; keep only V as its last row holds the homography.
    [~, ~, V] = svd(A);
    
    % Extract the homography H from the right singular vectors.
    H = reshape(V(:,9), 3, 3)';
end
