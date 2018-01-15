function [energy] = energy_garment(x, mesh_scan, mesh_smpl, garment_smpl, garment_scan, smpl_param)

global smpl_model;
global n_smpl;

L = x(25:end, :);
theta = reshape(x(1:24, :), 72, 1)';

sigma = 0.1;
energy = 0;

% w_g = 1000;
% w_b = 20;
% w_c = 1.5;
% w_s = 200;
% w_a = 20;

w_g = 1;
w_b = 10;
w_c = 1.5;
w_s = 1000;
w_a = 20;

% 1st data term
vertices_scan = mesh_scan.vertices(garment_scan.vertices_ind, :);
normals_scan = mesh_scan.normals(garment_scan.vertices_ind, :);
normals_smpl = mesh_smpl.normals(garment_smpl.vertices_ind, :);

nearest_ind_d2m = knnsearch(L, vertices_scan);
error_n = dot(normals_scan.', normals_smpl(nearest_ind_d2m, :).').';
mask_d2m = find(error_n > 0.8);
nearest_pts_d2m = vertices_scan(mask_d2m, :);
nearest_ind_d2m = nearest_ind_d2m(mask_d2m);

nearest_ind_m2d = knnsearch(vertices_scan, L);
nearest_pts_m2d = vertices_scan(nearest_ind_m2d, :);
error_n = dot(normals_scan(nearest_ind_m2d, :).', normals_smpl.').';
mask_m2d = find(error_n > 0.8);
nearest_pts_m2d = nearest_pts_m2d(mask_m2d, :);

error_d2m = nearest_pts_d2m - L(nearest_ind_d2m, :);
error_m2d = nearest_pts_m2d - L(mask_m2d, :);

energy = energy + w_g * (...
    sum(sum(error_d2m.^2 ./ (error_d2m.^2 + sigma^2))) + ...
    sum(sum(error_m2d.^2 ./ (error_m2d.^2 + sigma^2))));

% nearest_ind = knnsearch(L, vertices_scan);
% error_data = vertices_scan - L(nearest_ind, :);
% energy = energy + w_g * sum(sum(error_data.^2 ./ (error_data.^2 + sigma^2)));

% 2nd boundary term 
vertices_smpl_boundary = L(garment_smpl.boundary_local_ind, :);
vertices_scan_boundary = vertices_scan(garment_scan.boundary_local_ind, :);
normals_smpl_boundary = mesh_smpl.normals(garment_smpl.boundary_ind, :);
normals_scan_boundary = mesh_scan.normals(garment_scan.boundary_ind, :);

nearest_ind_d2m = knnsearch(vertices_smpl_boundary, vertices_scan_boundary);
error_n = dot(normals_scan_boundary.', normals_smpl_boundary(nearest_ind_d2m, :).').';
mask_d2m = find(error_n > 0.5);
nearest_pts_d2m = vertices_scan_boundary(mask_d2m, :);
nearest_ind_d2m = nearest_ind_d2m(mask_d2m);

nearest_ind_m2d = knnsearch(vertices_scan_boundary, vertices_smpl_boundary);
nearest_pts_m2d = vertices_scan_boundary(nearest_ind_m2d, :);
error_n = dot(normals_scan_boundary(nearest_ind_m2d, :).', normals_smpl_boundary.').';
mask_m2d = find(error_n > 0.5);
nearest_pts_m2d = nearest_pts_m2d(mask_m2d, :);

error_d2m = nearest_pts_d2m - vertices_smpl_boundary(nearest_ind_d2m, :);
error_m2d = nearest_pts_m2d - vertices_smpl_boundary(mask_m2d, :);
energy = energy + w_b * (...
    sum(sum(error_d2m.^2 ./ (error_d2m.^2 + sigma^2))) + ...
    sum(sum(error_m2d.^2 ./ (error_m2d.^2 + sigma^2)))); 

% 3rd coupling term
[beta, ~, trans, scale] = divideParam(smpl_param);
[v_shaped, j_shaped] = calShapedMesh(smpl_model, beta);
[v_posed] = calPosedMesh(smpl_model, theta, v_shaped, j_shaped, 0);
v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;
v_posed_garment = v_posed(garment_smpl.vertices_ind, :);

error_coupling = norm(L - v_posed_garment, 'fro');
energy = energy + w_c * error_coupling;

% 4th laplacian term:
Z = mesh_smpl.adjacency_map( ...
    garment_smpl.vertices_ind, garment_smpl.vertices_ind);
vertices_degree = sum(Z, 2);
H = diag(vertices_degree);
I = eye(length(vertices_degree));
G = I - H \ Z;
product = G * L;

error_laplacian = norm(product, 'fro');
energy = energy + w_s * error_laplacian;

% 5th boundary smoothness term
    

end

