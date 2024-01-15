function [s, h] = line_integral_rc(data, source_r, source_c, dexel_r, dexel_c)
% INPUTS
% data - data matrix to simulate ct imaging through
% source_r - r coordinate for the x-ray beam source
% source_c - c coordinate for the x-ray beam source
% dexel_r - r coordinate for the x-ray beam detector
% dexel_c - c coordinate for the x-ray beam detector
% 
% OUTPUTS
% s - attenuation signal for the x-ray beam at the detector
% h - normalization factor

% extract size of data for limits to simulation
[data_x,data_y] = size(data);

% Initiate attenuation variables to iterate a summation
s = 0; % total attenuation
a = zeros(1); % row vector of pixel intersection lengths

% source location
b = [source_c source_r];

% x-ray beam vector
d = [dexel_c-source_c dexel_r-source_r];

% x-ray beam vector magnitude
norm_scalar = sqrt( (dexel_c-source_c)^2 + (dexel_r-source_r)^2 );

% normalized x-ray beam vector
d_norm = d/norm_scalar;

% iteration 
delta_s = .05;

% for loop to iterate value of s over entire d vector
for i = 0:norm_scalar/delta_s
    c = round(b(1)); % c coordinate for the data vector at current position
    r = round(b(2)); % r coordinate for the data vector at current position
    b = b + delta_s*d_norm; % increase point b from source to detector

    % increase p only if position is within the data matrix
    if (0<c) && (c<=data_x) && (0<r) && (r<=data_y)
        length = length + delta_s;
        s = s + delta_s*data(r,c); % iterate the value of s
        % a(counter) = s_pixel;
        disp(s)
    else
        continue
    end
end

s = length
h = a*(a.');
h = 0;

end