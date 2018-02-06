function [label] = prior_pants(mesh)

%% likely to be pants
mask_likely = mesh.vertices(:, 2) > -0.947551 & mesh.vertices(:, 2) < -0.384934;

%% unlikely to be pants
mask_unlikely_0 = mesh.vertices(:, 2) > -0.091166;
mask_unlikely_1 = mesh.vertices(:, 2) < -1.16301;
mask_unlikely = mask_unlikely_0 | mask_unlikely_1;

%% get the label
label = ones(size(mesh.vertices, 1), 1) * 0.5;
label(mask_likely) = 1;
label(mask_unlikely) = 0;

end

