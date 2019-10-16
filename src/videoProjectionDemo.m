% Clear workspace, command window, and close extra windows
clc;
clear;
close all;

% Load necessary videos
vidSrc = getVideo('../res/ar_source.mov');
vidDst = getVideo('../res/book.mov');

% Load image for homography calculation
img = imread('../res/cv_cover.jpg');

% Set the number of frames to compute for
numFrames = size(vidDst,2);

% Set whether to display composite frames and whether to write to file
displayComp = 0;
writeVideo  = 0;

for frame = 1 : numFrames
    
    % Load the source and destination frame images from videos
    srcFrame = vidSrc(max(1,mod(frame, size(vidSrc,2)))).cdata;
    dstFrame = vidDst(frame).cdata;
    
    %% Step 1: Compute match between destination frame and book image
    % Detect matching features between source frame and book image
    [locs1, locs2] = findImgMatches(img, dstFrame);

    % Calculate the homography between the two point matrices
    [H_book, inliers] = calcRansacHomography(locs1, locs2);
    
    %% Step 2: Resize source video frame to proper dimensions & crop
    % Crop black bars out of source video
    srcFrame = srcFrame(50:size(srcFrame,1)-50,:,:);
    
    % Calculate dimensions for cropping the image
    ratio  = size(img,2) / size(img,1);
    height = size(srcFrame,1);
    width  = round(height * ratio);
    center = size(srcFrame,2)/2;
    left   = center-width/2;
    right  = center+width/2;
    
    % Crop the image to only include the center of it
    srcFrame = srcFrame(:,left:right,:);
    
    % Resize the frame to be mapped to the size of the book cover
    srcFrame = imresize(srcFrame, [size(img,1) size(img,2)]);
     
    
    %% Step 3: Determine and save the composite image of the two frames
    % Compute the composite image
    composite_img = compImgByHomography(inv(H_book), srcFrame, dstFrame);
    
    % Save the composite image for this iteration for writing
    b(frame).cdata = composite_img;
    b(frame).colormap = [];

    %% Step 4: Display composite image
    % If image is supposed to be displayed, show it
    if displayComp == 1
        imshow(b(frame).cdata);
        title(['Frame ', num2str(frame), ' of the Augmented Reality Video'],...
            'fontsize', 20);
    end
    
    % Print status message
    fprintf('Frame %d calculated\n', frame);
end

%% Write the image to file if set
% If we want to write images to file, save the video
if writeVideo == 1
    
    % Open a struct to write images to file
    v = VideoWriter('../results/abc', 'Archival');

    % Open the file, write frame data to file, and then close it
    open(v);
    fprintf('\n');
    for i = 1 : numFrames
        writeVideo(v, b(i));
        fprintf('Frame %d written\n', i);
    end
    close(v);
end