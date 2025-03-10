function phantom_smooth(vmin, vmax)
% INPUTS
% vmin - minimum display window
% vmax - maximum display window
% 
% OUTPUTS

disp("Running: phantom_smooth.m")

%% Original Data and Mask
% Load Data
phantom_data = load('phantom_sino.mat');
phantom_sino = phantom_data.sino;
% Load Mask
mask = load('phantom_mask.mat');
mask_sino_logical = mask.mask_sino_logical;

%% Smoothing
% Invert mask
mask_sino_invert = ~mask_sino_logical;

% Original sinogram without metal data
phantom_sino_invert = phantom_sino.*mask_sino_invert;

% List the Smoothing techniques used
smooth_type = ["movmean", "movmedian"];

% Initialize Variables
phantom_smoothing   = zeros(size(phantom_sino,1),size(phantom_sino,2),1);
phantom_sino_masked = phantom_smoothing;
phantom_sinogram    = phantom_smoothing;
reconstruction      = zeros(520,520,1);

% Iteration through types of filtering
for i=1:length(smooth_type)

    % Smooth with current smoothing type
    phantom_smoothing(:,:,i) = smoothdata(phantom_sino,smooth_type(i));
    
    % Find intersection of mask and smooth data
    phantom_sino_masked(:,:,i) = phantom_smoothing(:,:,i).*mask_sino_logical;
    
    % Combine smoothed data and orginial data
    phantom_sinogram(:,:,i) = phantom_sino_invert + phantom_sino_masked(:,:,i);
    
    % Reconstruct the image
    reconstruction(:,:,i) = reconstruct(phantom_sinogram(:,:,i));
end

% Create Hybrid Smoothing Type
% The first two smoothing techniques produce mixed results, each of these
% techniques target an area with metal present, but neither target both
% areas. Combination simply averages bothe techniques in attempt to improve
% the smoothing results.
phantom_smoothing(:,:,3) = (phantom_smoothing(:,:,1) + phantom_smoothing(:,:,2))/2; % Combine Gaussian with Average
% Find intersection of mask and smooth data
phantom_sino_masked(:,:,3) = phantom_smoothing(:,:,3).*mask_sino_logical;
% Combine smoothed data and orginial data
phantom_sinogram(:,:,3) = phantom_sino_invert + phantom_sino_masked(:,:,3);
% Reconstruct the image
reconstruction(:,:,3) = reconstruct(phantom_sinogram(:,:,3));

% Visualize Smoothing Technique
fig_1 = figure('units','normalized','outerposition',[0 0 1 .75]);
% Plot Masked Sinogram
subplot(1,4,1)
masked_sinogram_orginal = zeros(size(phantom_sino_invert,1),size(phantom_sino_invert,2),3);
masked_sinogram_orginal(:,:,1) = phantom_sino_invert;
masked_sinogram_orginal(:,:,2) = phantom_sino_invert;
imshow(masked_sinogram_orginal)
img_title = {"Initial Sinogram","AND","Inverted Mask"};
title(img_title,'FontSize',24)
% Plot Intersectino with Mask and Smoothed Sinogram
subplot(1,4,2)
masked_sinogram_smoothed = zeros(size(phantom_sino_invert,1),size(phantom_sino_invert,2),3);
masked_sinogram_smoothed(:,:,3) = phantom_sino_masked(:,:,1);
imshow(masked_sinogram_smoothed)
img_title = {"Smoothed Sinogram","AND","Mask"};
title(img_title,'FontSize',24)
% Plot Colorized Hybrid Sinogram
subplot(1,4,3)
hybrid_sinogram = masked_sinogram_smoothed + masked_sinogram_orginal;
imshow(hybrid_sinogram)
img_title = {"Hybrid Sinogram","Colorized"};
title(img_title,'FontSize',24)
% Plot Grayscale Hybrid Sinogram
subplot(1,4,4)
imshow(phantom_sinogram(:,:,1))
img_title = {"Hybrid Sinogram","Grayscale"};
title(img_title,'FontSize',24)
colormap gray(256)
saveas(fig_1,'figures/smoothing_technique.jpg'); % save figure

% Visualize the sinograms and reconstructions
fig_2 = figure('units','normalized','outerposition',[0 0 1 1]);
% Set Title strings for plot iteration
titles = ["Average"; 
          "Median";
          "Combined"];
% Iterate Through Image Arrays
for i=1:size(reconstruction,3)
    % Plot Sinogram
    subplot(2,3,i)
    imagesc(phantom_sinogram(:,:,i), [0 7])
    colormap gray(256)
    title(titles(i),'FontSize',36)
    axis('square')
    if i==1
        ylabel("Sinogram",'FontSize',36)
    end
    xticklabels ''
    yticklabels ''
    % Plot Reconstruction
    subplot(2,3,i+3)
    imagesc(reconstruction(:,:,i), [vmin vmax]);
    colormap gray(256)
    axis('square')
    if i==1
        ylabel("Reconstruction",'FontSize',36)
    end
    xticklabels ''
    yticklabels ''
end
saveas(fig_2,'figures/phantom_smoothing_results.jpg'); % save figure

end
