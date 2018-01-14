function [energy] = energy_garment(x, mesh_scan, mesh_smpl, garment_smpl, garment_scan, smpl_param)

global smpl_model;
global n_smpl;

L = x(25:end, :);
theta = reshape(x(1:24, :), 72, 1)';

sigma = 0.1;
energy = 0;

w_g = 100;
w_b = 20;
w_c = 1.5;
w_s = 200;
w_a = 20;

% 1st data term
mesh_scan_garment = mesh_scan.vertices(garment_scan.vertices_ind, :);
normals_scan_garment = mesh_scan.normals(garment_scan.vertices_ind, :);
normals_smpl_garment = mesh_smpl.normals(garment_smpl.vertices_ind, :);

nearest_ind_d2m = knnsearch(L, mesh_scan_garment);
error_n = dot(normals_scan_garment.', normals_smpl_garment(nearest_ind_d2m, :).').';
mask_d2m = find(error_n > 0.5);
nearest_pts_d2m = mesh_scan_garment(mask_d2m, :);
nearest_ind_d2m = nearest_ind_d2m(mask_d2m);

nearest_ind_m2d = knnsearch(mesh_scan_garment, L);
nearest_pts_m2d = mesh_scan_garment(nearest_ind_m2d, :);
error_n = dot(normals_scan_garment(nearest_ind_m2d, :).', normals_smpl_garment.').';
mask_m2d = find(error_n > 0.5);
nearest_pts_m2d = nearest_pts_m2d(mask_m2d, :);

error_d2m = nearest_pts_d2m - L(nearest_ind_d2m, :);
error_m2d = nearest_pts_m2d - L(mask_m2d, :);

energy = energy + w_g * (...
    sum(sum(error_d2m.^2 ./ (error_d2m.^2 + sigma^2))) + ...
    sum(sum(error_m2d.^2 ./ (error_m2d.^2 + sigma^2))));

% 2nd boundary term 
mesh_smpl_boundary = L(garment_smpl.boundary_local_ind, :);
mesh_scan_boundary = mesh_scan_garment(garment_scan.boundary_local_ind, :);
normals_smpl_boundary = mesh_smpl.normals(garment_smpl.boundary_ind, :);
normals_scan_boundary = mesh_scan.normals(garment_scan.boundary_ind, :);

nearest_ind_d2m = knnsearch(mesh_smpl_boundary, mesh_scan_boundary);
error_n = dot(normals_scan_boundary.', normals_smpl_boundary(nearest_ind_d2m, :).').';
mask_d2m = find(error_n > 0.5);
nearest_pts_d2m = mesh_scan_boundary(mask_d2m, :);
nearest_ind_d2m = nearest_ind_d2m(mask_d2m);

nearest_ind_m2d = knnsearch(mesh_scan_boundary, mesh_smpl_boundary);
nearest_pts_m2d = mesh_scan_boundary(nearest_ind_m2d, :);
error_n = dot(normals_scan_boundary(nearest_ind_m2d, :).', normals_smpl_boundary.').';
mask_m2d = find(error_n > 0.5);
nearest_pts_m2d = nearest_pts_m2d(mask_m2d, :);

error_d2m = nearest_pts_d2m - mesh_smpl_boundary(nearest_ind_d2m, :);
error_m2d = nearest_pts_m2d - mesh_smpl_boundary(mask_m2d, :);
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

