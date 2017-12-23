function single_mesh(mesh)

% s1_scale_scan
mesh_scaled_scan = single_mesh_scale(mesh, 1000);

% s2_align_scan
param_init = single_mesh_trans(mesh_scaled_scan);

% s3_fit_scan
[param_fitted_smpl, mesh_fitted_smpl] = single_mesh_fitting(mesh_scaled_scan, param_init);

% s4_opt_single_mesh_3s_GMdist
[m_smpl, m_A, param] = single_mesh_align(mesh_scaled_scan, mesh_fitted_smpl, param_fitted_smpl);


end
