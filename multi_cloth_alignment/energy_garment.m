function [energy] = energy_garment(x, mesh_garment_scan, boundary_smpl, boundary_scan, ...
    normals_smpl, normals_scan)
    L = x;
   
    sigma = 0.1;
    energy = 0;

    % first data term
    nearest_ind_d2m = knnsearch(L, mesh_garment_scan);
    error_n = dot(normals_scan.', normals_smpl(nearest_ind_d2m, :).').';
    mask_d2m = find(error_n > 0);
    nearest_pts_d2m = mesh_garment_scan(mask_d2m, :);
    nearest_ind_d2m = nearest_ind_d2m(mask_d2m);
    
    nearest_ind_m2d = knnsearch(mesh_garment_scan, L);
    nearest_pts_m2d = mesh_garment_scan(nearest_ind_m2d, :);
    error_n = dot(normals_scan(nearest_ind_m2d, :).', normals_smpl.').';
    mask_m2d = find(error_n > 0);
    nearest_ind_m2d = nearest_ind_m2d(mask_m2d);
    nearest_pts_m2d = nearest_pts_m2d(mask_m2d, :);
    
    error = nearest_pts_d2m - L(nearest_ind_d2m, :);
    energy = energy + sum(sum(error.^2 ./ (error.^2 + sigma^2)));

    error = nearest_pts_m2d - L(mask_m2d, :);
    energy = energy + sum(sum(error.^2 ./ (error.^2 + sigma^2)));

end

