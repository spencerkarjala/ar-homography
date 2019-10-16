%% PURPOSE: Create composite by warping the template image with homography
%  INPUT:   H2to1 is the homography, template is the template image, and
%           img is the image to put on top of the template
%  OUTPUT:  composite_img is the superposition of the resulting images
function [composite_img] = compImgByHomography(H2to1, template, img)
    %% Create mask of same size as template
    mask   = ones(size(template));

    %% Warp mask by appropriate homography
    mask_t = ones(size(img)) - double(warpImgByHomography(mask, ...
            H2to1, size(img)));

    %% Warp template by appropriate homography
    template_t = double(warpImgByHomography(template, H2to1, size(img)));

    %% Use mask to combine the warped template and the image
    composite_img = uint8((double(img) .* mask_t) + template_t);
end