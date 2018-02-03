function [param] = single_mesh_trans(mesh)

global smpl_model;
global mesh_prefix;
global mesh_prefix_last;
global result_dir;
global result_dir_base;

max_iter = 1;

% vertices in SMPL model
n_smpl = size(smpl_model.v_template, 1);

n_rand = size(mesh.normals, 1);
rand_ind = randperm(size(mesh.vertices, 1));

vertices = mesh.vertices(rand_ind(1:n_rand), :);
normals = mesh.normals(rand_ind(1:n_rand), :);

% no previous frame, init param
if isempty(mesh_prefix_last)
	betas = zeros(1, 10);
    pose = zeros(1, 72);
    pose(2) = pi;
    pose(51) = -5 * pi/24;
    pose(54) = 5 * pi/24;
    trans = zeros(1, 3);
    trans(2) = 1.1448;
    scale = 1;
    param = combineParam(betas, pose, trans, scale);
else
    param_path = [result_dir_base, filesep, mesh_prefix_last];
    param_name = [mesh_prefix_last, '_fit_param.mat'];
    param = load([param_path, filesep, param_name]);
    param = param.param;    
end

[betas, pose, trans, scale] = divideParam(param);
[v_shaped, j_shaped] = calShapedMesh(smpl_model, betas);
[v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
[v_posed] = repmat(trans, n_smpl, 1) + v_posed * scale;

mesh_out.vertices = v_posed;
mesh_out.faces = smpl_model.f + 1;

mesh_file = [result_dir, filesep, mesh_prefix, '_init.obj'];
mesh_exporter(mesh_file, mesh_out);

param = estimate_trans(smpl_model, vertices, normals, max_iter, param);

[betas, pose, trans, scale] = divideParam(param);
[v_shaped, j_shaped] = calShapedMesh(smpl_model, betas);
[v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
[v_posed] = repmat(trans, n_smpl, 1) + v_posed * scale;

mesh_out.vertices = v_posed;
mesh_out.faces = smpl_model.f + 1;

mesh_file = [result_dir, filesep, mesh_prefix, '_trans.obj'];
param_file = [result_dir, filesep, mesh_prefix, '_trans_param.mat'];

mesh_exporter(mesh_file, mesh_out);
save(param_file, 'param');

end