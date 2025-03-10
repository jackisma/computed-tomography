function phantom_mask(vmin, vmax)
% INPUTS
% vmin - minimum display window
% vmax - maximum display window
% 
% OUTPUTS

disp("Running: phantom_mask.m")

%% Original Data
% Load data
phantom_data = load('phantom_sino.mat');
phantom_sino = phantom_data.sino; 

% Reconstruct the Data
phantom_reconstruction = reconstruct(phantom_sino);

% Visualize Original Sinogram and Reconstruction
fig_1 = figure('units','normalized','outerposition',[0 0 1 .75]);
% Plot the Initial Data (sinogram)
subplot(1,2,1)
imagesc(phantom_sino);
colormap gray(256)
img_title = "Original Sinogram";
title(img_title,'FontSize',48)
axis off
% Plot Reconstruction of Initial Data
subplot(1,2,2)
imagesc(phantom_reconstruction, [vmin, vmax]);
colormap gray(256)
img_title = "Reconstruction";
title(img_title,'FontSize',48)
axis off
saveas(fig_1,'figures/phantom_sino_original_data.jpg'); % save figure

%% Create the Mask
% Dialate the reconstruction image
dilation = imdilate(phantom_reconstruction, strel('sphere',2));
% Dialate image again to fill smaller gaps
dilation_2 = imdilate(dilation, strel('sphere',1)); 
% Remove values by threshold
% mask_img = dilation;
% mask_img(dilation<=0.019) = 0;
mask_img = dilation_2;
mask_img(dilation_2<=0.029) = 0;

% Forward project mask
mask_sino = forwardproject(mask_img);
% Convert Mask Sinogram to logical (0 or 1)
mask_sino_logical = mask_sino;
mask_sino_logical(mask_sino_logical~=0) = 1;

% Visualization of Mask
fig_2 = figure('units','normalized','outerposition',[0 0 1 .55]);
% Plot Reconstruction Image
subplot(1,4,1)
imagesc(phantom_reconstruction, [vmin vmax]);
colormap gray(256);
img_title = {'Original Data';'Reconstruction'};
title(img_title,'FontSize',36)
axis off
% Plot Metal Mask
subplot(1,4,2)
imagesc(mask_img, [vmin vmax]);
colormap gray(256);
img_title = "Metal Mask";
title(img_title,'FontSize',36)
axis off
% Plot Mask Sinogram
subplot(1,4,3)
imagesc(mask_sino);
colormap gray(256);
img_title = {'Metal Mask';'Sinogram'};
title(img_title,'FontSize',36)
axis off
% Plot Logical of Mask Sinogram
subplot(1,4,4)
imagesc(mask_sino_logical);
colormap gray(256);
img_title = {'Metal Mask';'Logical'};
title(img_title,'FontSize',36)
axis off
saveas(fig_2,'figures/phantom_sino_metal_mask_creation.jpg'); % save figure

% Save the mask data
save('phantom_mask.mat','mask_sino_logical'); 

%% Create Masked Image
% Invert the mask
mask_sino_invert = ~mask_sino_logical;
% Singram intersection with inverted mask
masked_sinogram = phantom_sino.*mask_sino_invert;
% Reconstruct the masked sinogram
masked_reconstruction = reconstruct(masked_sinogram);

% Visualization of Mask and New Reconstruction
fig_3 = figure('units','normalized','outerposition',[0 0 1 .75]);
% Plot Masked Sinogram
subplot(1,2,1)
imagesc(masked_sinogram)
colormap gray(256)
img_title = "Masked Sinogram";
title(img_title,'FontSize',48)
axis off
% Plot Reconstruction of Masked Sinogram
subplot(1,2,2)
imagesc(masked_reconstruction, [vmin vmax])
colormap gray(256)
img_title = "Masked Reconstruction";
title(img_title,'FontSize',48)
axis off
saveas(fig_3,'figures/phantom_sino_metal_mask_results.jpg'); % save image

end