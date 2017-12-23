function [label] = prior_shirt(mesh)

%% likely to be t-shirt
mask_likely_0 = mesh.vertices(:, 2) < 0.134339 & mesh.vertices(:, 2) > -0.166764;
mask_likely = mask_likely_0;

%% unlikely to be t-shirt
mask_unlikely_0 = mesh.vertices(:, 2) > 0.299678;
mask_unlikely_1 = mesh.vertices(:, 2) < -0.340797;
mask_unlikely_2 = mesh.vertices(:, 1) > 0.442744;
mask_unlikely_3 = mesh.vertices(:, 1) < -0.42223;
mask_unlikely = mask_unlikely_0 | mask_unlikely_1 | mask_unlikely_2 | mask_unlikely_3;

%% get the label
label = ones(size(mesh.vertices, 1), 1) * 0.5;
label(mask_likely) = 1;
label(mask_unlikely) = 0;

end

