function [prior_scan] = get_scan_prior(mesh_smpl, mesh_scan, prior_smpl)

nearest_ind = knnsearch(mesh_smpl.vertices, mesh_scan.vertices);

prior_scan_skin = prior_smpl.skin(nearest_ind);
prior_scan_shirt = prior_smpl.shirt(nearest_ind);
prior_scan_pants = prior_smpl.pants(nearest_ind);

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

