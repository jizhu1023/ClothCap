function [] = gmm_fitting(mesh_scan, label_scan)

global is_first;
global mesh_prefix;
global mesh_prefix_last;
global result_dir;
global result_dir_base;	

k = 3;

colors_hsv = rgb2hsv(double(mesh_scan.colors) / 255);
colors_skin = colors_hsv(label_scan == 0, :);
colors_shirt = colors_hsv(label_scan == 1, :);
colors_pants = colors_hsv(label_scan == 2, :);

if is_first == 1
    mu = zeros(k, 3);
    mu(1, :) = mean(colors_skin);
    mu(2, :) = mean(colors_shirt);
    mu(3, :) = mean(colors_pants);

    sigma = zeros(3, 3, k);
    sigma(:, :, 1) = cov(colors_skin);
    sigma(:, :, 2) = cov(colors_shirt);
    sigma(:, :, 3) = cov(colors_pants);

    components = [size(colors_skin, 1), size(colors_shirt, 1), ...
        size(colors_pants, 1)]  / size(mesh_scan.colors, 1);
else
    colors_path = [result_dir_base, filesep, mesh_prefix_last];
    colors_name = [mesh_prefix_last, '_colors.mat'];
    colors_prev = load([colors_path, filesep, colors_name]);
    colors_prev = colors_prev.colors_prev;

    colors_skin = [colors_skin; colors_prev.skin];
    colors_shirt = [colors_shirt; colors_prev.shirt];
    colors_pants = [colors_pants; colors_prev.pants];
    colors_hsv = [colors_skin; colors_shirt; colors_pants];
    
    gmm_path = [result_dir_base, filesep, mesh_prefix_last];
    gmm_name = [mesh_prefix_last, '_gmm.mat'];
    gmm_prev = load([gmm_path, filesep, gmm_name]);
    gmm_prev = gmm_prev.gmm;
    
    mu = gmm_prev.mu;
    sigma = gmm_prev.Sigma;
    components = gmm_prev.ComponentProportion;
end

S = struct('mu', mu, 'Sigma', sigma, ...
    'ComponentProportion', components);
options = statset('Display', 'final', 'MaxIter', 1000);

% gmm_skin = fitgmdist(colors_skin, 3, 'Start', S, 'Options', options);
% gmm_shirt = fitgmdist(colors_shirt, 3, 'Start', S, 'Options', options);
% gmm_pants = fitgmdist(colors_pants, 3, 'Start', S, 'Options', options);
% 
% gmm.skin = gmm_skin;
% gmm.shirt = gmm_shirt;
% gmm.pants = gmm_pants;

gmm = fitgmdist(colors_hsv, 3, 'Start', S, 'Options', options);
save([result_dir, filesep, mesh_prefix, '_gmm.mat'], 'gmm');

colors_prev.skin = colors_skin;
colors_prev.shirt = colors_shirt;
colors_prev.pants = colors_pants;
save([result_dir, filesep, mesh_prefix, '_colors.mat'], 'colors_prev');

end

