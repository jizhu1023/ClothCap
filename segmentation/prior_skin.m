function [label] = prior_skin(mesh)

%% likely to be skin
mask_likely_0 = mesh.vertices(:, 2) > 0.329678;
mask_likely_1 = mesh.vertices(:, 2) < -1.17301;
mask_likely_2 = mesh.vertices(:, 1) > 0.442744;
mask_likely_3 = mesh.vertices(:, 1) < -0.42223;
mask_likely = mask_likely_0 | mask_likely_1 | mask_likely_2 | mask_likely_3;

%% unlikely to be skin
mask_unlikely_0 = mesh.vertices(:, 2) < 0.134339 & mesh.vertices(:, 2) > -0.166764;
mask_unlikely_1 = mesh.vertices(:, 2) < -0.235831 & mesh.vertices(:, 2) > -0.967478;
mask_unlikely = mask_unlikely_0 | mask_unlikely_1;

%% get the label
label = ones(size(mesh.vertices, 1), 1) * 0.5;
label(mask_likely) = 1;
label(mask_unlikely) = 0;

end