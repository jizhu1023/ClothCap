function [vertices, pose] = align_garment(garment_scan, garment_smpl, ...
    mesh_scan, mesh_smpl, label_smpl, pose_init, garment_prefix, iter_num)

global mesh_prefix;
global result_dir;
global use_python;

if use_python == false

tmp_result_folder = [result_dir, filesep, ...
    mesh_prefix, '_garments_', garment_prefix];
mkdir(tmp_result_folder);

theta = reshape(pose_init, 24, 3);
L = mesh_smpl.vertices(garment_smpl.vertices_ind, :);

mesh_smpl_tmp = mesh_smpl;

for iter = 1 : 1
    
    mesh_smpl_tmp.vertices(garment_smpl.vertices_ind, :) = L;
    mesh_smpl_tmp.normals = calNormal( ...
        mesh_smpl_tmp.faces, mesh_smpl_tmp.vertices);
    
    param = [theta; L];
    
    options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
        'Display', 'iter-detailed', 'MaxIter', iter_num);
    param_opt = lsqnonlin(@(x) energy_garment(x, mesh_scan, mesh_smpl_tmp, ...
        garment_smpl, garment_scan), param, [], [], options);

    L = param_opt(25:end, :);
    theta = param_opt(1:24, :);
    
    mesh_name_full = sprintf([garment_prefix, '_full_iter_%02d.obj'], iter);
    mesh_name_part = sprintf([garment_prefix, '_part_iter_%02d.obj'], iter);
    
    mesh_full = mesh_smpl_tmp;
    mesh_full.vertices(garment_smpl.vertices_ind, :) = L;
    mesh_full.colors = render_labels(label_smpl);
    mesh_exporter([tmp_result_folder, filesep, mesh_name_full], mesh_full, true);
    
    mesh_part = mesh_full;
    mesh_part.faces = mesh_full.faces(garment_smpl.faces_ind, :);
    mesh_exporter([tmp_result_folder, filesep, mesh_name_part], mesh_part, true);
end

mesh_exporter([result_dir, filesep, mesh_prefix, ...
    '_', garment_prefix, '_full.obj'], mesh_full, true);
mesh_exporter([result_dir, filesep, mesh_prefix, ...
    '_', garment_prefix, '_part.obj'], mesh_part, true);

vertices = L;
pose = reshape(theta, 1, 72);

else

% param = mesh_smpl.vertices(garment_smpl.vertices_ind, :);
% 
% m_scan.vertices = mesh_scan.vertices;
% m_scan.normals = mesh_scan.normals;
% 
% m_smpl.vertices = mesh_smpl.vertices;
% m_smpl.normals = mesh_smpl.normals;
% m_smpl.adjacency_map = mesh_smpl.adjacency_map;
% 
% save('python/data/multi_cloth_opt_params.mat', 'param');
% save('python/data/multi_cloth_opt_meshes.mat', 'm_scan', 'm_smpl');
% save('python/data/multi_cloth_opt_garments.mat', 'garment_scan', 'garment_smpl');
% save('python/data/multi_cloth_opt_smpl_param.mat', 'smpl_param');
  
end

end