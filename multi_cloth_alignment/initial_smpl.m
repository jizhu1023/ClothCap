function [label_smpl, mesh_smpl, garments_smpl] = initial_smpl(mesh_folder, result_dir_base)

global smpl_model;
global smpl_param;
global n_smpl;

% load SMPL label from 1st frame
label_smpl = load(['all_results/segmentation/', mesh_folder, '/individual_1st_label_smpl.mat']);
label_smpl = label_smpl.seg_smpl;  

n_smpl = length(label_smpl);

% person-specialized shape and pose
smpl_param = load(['all_results/single_mesh/', mesh_folder, '/individual_1st_aligned_param.mat']);
smpl_param = smpl_param.param;

% load SMPL mean shape and apply
[betas, pose, trans, scale] = divideParam(smpl_param);
[v_shaped, j_shaped] = calShapedMesh(smpl_model, betas);
[v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;

mesh_smpl = mesh_parser('smpl_base_m.obj', 'smpl_model');
mesh_smpl.vertices = v_posed;
mesh_smpl.normals = calNormal(mesh_smpl.faces, mesh_smpl.vertices);

% get the smpl model garments
[garments_smpl, mesh_garments_smpl] = extract_garments(mesh_smpl, label_smpl);
mesh_exporter([result_dir_base, '/smpl_garments.obj'], mesh_garments_smpl, true);
save([result_dir_base, '/smpl_garments.mat'], 'garments_smpl');

end
