function [param_fitted, mesh_fitted] = single_mesh_fitting(mesh, param_init)

global is_first;
global smpl_model;
global mesh_prefix;
global result_dir;

% vertices in SMPL model
n_smpl = size(smpl_model.v_template, 1);

max_iter = 50;
if_shape = 1;

% not first frame
if is_first == 0
    max_iter = 10;
	if_shape = 0;
end

param_tmp = param_init;
param_tmp(end) = 1;

param_fitted = estimate_fitting(smpl_model, mesh.vertices, mesh.normals, max_iter, ...
    if_shape, param_tmp, mesh_prefix, result_dir);

[betas, pose, trans, scale] = divideParam(param_fitted);
[v_shaped, j_shaped] = calShapedMesh(smpl_model, betas);
[v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
[v_posed] = repmat(trans, n_smpl, 1) + v_posed * scale;

mesh_fitted.vertices = v_posed;
mesh_fitted.faces = smpl_model.f + 1;

mesh_file = [result_dir, filesep, mesh_prefix, '_fit.obj'];
param_file = [result_dir, filesep, mesh_prefix, '_fit_param.mat'];

mesh_exporter(mesh_file, mesh_fitted);
param = param_fitted;
save(param_file, 'param');

end

