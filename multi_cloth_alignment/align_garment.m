function [vertices, pose] = align_garment(garment_scan, garment_smpl, ...
    mesh_scan, mesh_smpl, label_smpl, pose_init, garment_prefix, iter_num)

global n_smpl;
global is_first;
global mesh_prefix;
global result_dir;
global use_python;
global smpl_param;

% variables to be optimized
theta = reshape(pose_init, 24, 3);
L = mesh_smpl.vertices(garment_smpl.vertices_ind, :);

% use MATLAB optimization
if use_python == false

tmp_result_folder = [result_dir, filesep, ...
    mesh_prefix, '_garments_', garment_prefix];
mkdir(tmp_result_folder);

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

% use python scipy solver
else

path_data = ['python', filesep, 'data'];
mkdir(path_data);

m_scan.vertices = mesh_scan.vertices;
m_scan.normals = mesh_scan.normals;
m_scan.faces = mesh_scan.faces;

m_smpl.vertices = mesh_smpl.vertices;
m_smpl.normals = mesh_smpl.normals;
m_smpl.faces = mesh_smpl.faces;
m_smpl.adjacency_map = mesh_smpl.adjacency_map;

save([path_data, filesep, 'multi_cloth_opt_params.mat'], 'L', 'theta');
save([path_data, filesep, 'multi_cloth_opt_meshes.mat'], 'm_scan', 'm_smpl');
save([path_data, filesep, 'multi_cloth_opt_garments.mat'], 'garment_smpl', 'garment_scan');
save([path_data, filesep, 'multi_cloth_opt_smpl_param.mat'], 'smpl_param');
save([path_data, filesep, 'multi_cloth_opt_extra.mat'], 'is_first', 'n_smpl');

end

end