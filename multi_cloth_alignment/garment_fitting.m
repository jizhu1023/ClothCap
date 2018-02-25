function [] = garment_fitting( ...
    mesh_scan, label_scan, garments_scan, ...
    mesh_smpl, label_smpl, garments_smpl)

global is_first;
global n_smpl;
global result_dir;
global smpl_param;
global smpl_model;
global mesh_folder;
global mesh_prefix;
global mesh_prefix_last;

mesh_smpl_shirt = mesh_smpl;
mesh_smpl_pants = mesh_smpl;

param_path = ['all_results', filesep, 'single_mesh', ...
    filesep, mesh_folder, filesep, mesh_prefix];
param_name = [mesh_prefix, '_fit_param.mat'];
smpl_param = load([param_path, filesep, param_name]);
smpl_param = smpl_param.param;

[beta, ~, trans, scale] = divideParam(smpl_param);
[v_shaped, j_shaped] = calShapedMesh(smpl_model, beta);

if is_first == 1
    pose_shirt = smpl_param(11:82);
    pose_pants = smpl_param(11:82);

    v_posed = calPosedMesh(smpl_model, smpl_param(11:82), ...
        v_shaped, j_shaped, 0);
    v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;
    
    mesh_smpl_shirt.vertices = v_posed;
    mesh_smpl_pants.vertices = v_posed;
else
    param_path = ['all_results', filesep, 'multi_cloth', ...
        filesep, mesh_folder, filesep, mesh_prefix_last];
    param_name_shirt = [mesh_prefix_last, '_pose_shirt.mat'];
    param_name_pants = [mesh_prefix_last, '_pose_pants.mat'];
    pose_shirt = load([param_path, filesep, param_name_shirt]);
    pose_pants = load([param_path, filesep, param_name_pants]);
    pose_shirt = pose_shirt.theta_shirt;
    pose_pants = pose_pants.theta_pants;
    
    v_posed_shirt = calPosedMesh(smpl_model, pose_shirt, ...
        v_shaped, j_shaped, 0);
    v_posed_shirt = repmat(trans, n_smpl, 1) + v_posed_shirt * scale;
    
    v_posed_pants = calPosedMesh(smpl_model, pose_pants, ...
        v_shaped, j_shaped, 0);
    v_posed_pants = repmat(trans, n_smpl, 1) + v_posed_pants * scale;
    
    mesh_smpl_shirt.vertices = v_posed_shirt;
    mesh_smpl_pants.vertices = v_posed_pants;
end

mesh_exporter([result_dir, filesep, mesh_prefix, ...
    '_seg_smpl_shirt.obj'], mesh_smpl_shirt, true);
mesh_exporter([result_dir, filesep, mesh_prefix, ...
    '_seg_smpl_pants.obj'], mesh_smpl_pants, true);

% for skin    
% [vertices_skin, pose_skin] = align_skin(garments_scan.skin, garments_smpl.skin, ...
%     mesh_scan, mesh_smpl, label_smpl);
% save([result_dir, filesep, mesh_prefix, '_pose_skin.mat'], 'pose_skin');

% for shirt    
[vertices_shirt, theta_shirt] = align_garment(garments_scan.shirt, garments_smpl.shirt, ...
    mesh_scan, mesh_smpl_shirt, label_smpl, pose_shirt, 'shirt', 5);
save([result_dir, filesep, mesh_prefix, '_pose_shirt.mat'], 'theta_shirt');

% for pants    
[vertices_pants, theta_pants] = align_garment(garments_scan.pants, garments_smpl.pants, ...
    mesh_scan, mesh_smpl_pants, label_smpl, pose_pants, 'pants', 10);
save([result_dir, filesep, mesh_prefix, '_pose_pants.mat'], 'theta_pants');  

% combine all garments to one;
m_comined = mesh_smpl;
m_comined.vertices(garments_smpl.shirt.vertices_ind, :) = vertices_shirt;
m_comined.vertices(garments_smpl.pants.vertices_ind, :) = vertices_pants;
mesh_exporter([result_dir, filesep, mesh_prefix, ...
    '_combined_full.obj'], m_comined, true);

% for full mesh
% [vertices_all, pose] = align_cloth(garments_scan, garments_smpl, ...
%     mesh_scan, mesh_combined, label_smpl);
% save([result_dir, filesep, mesh_prefix, '_pose_pants.mat'], 'pose');

end