function [prior_scan] = get_scan_prior(mesh_smpl, mesh_scan, prior_smpl)

nearest_ind = knnsearch(mesh_scan.vertices, mesh_smpl.vertices);

n_scan = size(mesh_scan.vertices, 1);
prior_scan_skin = ones(n_scan, 1) * 0.5;
prior_scan_shirt = ones(n_scan, 1) * 0.5;
prior_scan_pants = ones(n_scan, 1) * 0.5;

skin_likely_ind = nearest_ind(prior_smpl.skin == 1, :);
skin_unlikely_ind = nearest_ind(prior_smpl.skin == 0, :);

shirt_likely_ind = nearest_ind(prior_smpl.shirt == 1, :);
shirt_unlikely_ind = nearest_ind(prior_smpl.shirt == 0, :);

pants_likely_ind = nearest_ind(prior_smpl.pants == 1, :);
pants_unlikely_ind = nearest_ind(prior_smpl.pants == 0, :);

% map back
prior_scan_skin(skin_likely_ind, :) = 1;
prior_scan_skin(skin_unlikely_ind, :) = 0;

prior_scan_shirt(shirt_likely_ind, :) = 1;
prior_scan_shirt(shirt_unlikely_ind, :) = 0;

prior_scan_pants(pants_likely_ind, :) = 1;
prior_scan_pants(pants_unlikely_ind, :) = 0;

% render and return
prior_scan.skin = prior_scan_skin;
prior_scan.shirt = prior_scan_shirt;
prior_scan.pants = prior_scan_pants;
 
m = mesh_scan;
m.colors = render_prior(prior_scan_skin);
mesh_exporter('segmentation/prior_base/prior_scan_skin.obj', m, true);

m.colors = render_prior(prior_scan_shirt);
mesh_exporter('segmentation/prior_base/prior_scan_shirt.obj', m, true);

m.colors = render_prior(prior_scan_pants);
mesh_exporter('segmentation/prior_base/prior_scan_pants.obj', m, true);

end

