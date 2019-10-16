%% Initialize the workspace
% Clear the workspace and command window and close windows
clc;
clear;
close all;

% Load data from file
cv_img = imread('../res/cv_cover.jpg');
desk_img = imread('../res/cv_desk.png');
hp_img = imread('../res/hp_cover.jpg');

%% Extract features and match
[locs1, locs2] = findImgMatches(cv_img, desk_img);

%% Compute homography using RANSAC
[bestH2to1, ~] = calcRansacHomography(locs1, locs2);

%% Scale harry potter image to template size
% Why is this is important?
scaled_hp_img = imresize(hp_img, [size(cv_img,1) size(cv_img,2)]);

%% Display warped image.
imshow(warpImgByHomography(scaled_hp_img, inv(bestH2to1), size(desk_img)));

%% Display composite image
imshow(compImgByHomography(inv(bestH2to1), scaled_hp_img, desk_img));
title('Harry-Potterized Textbook Using Homography from RANSAC', 'fontsize', 20);
