function [garment_vertices, pose] = align_garment(garment_scan, garment_smpl, ...
    mesh_scan, mesh_smpl, label_smpl, garment_prefix)

global smpl_param;
global mesh_prefix;
global result_dir;

tmp_result_folder = [result_dir, filesep, mesh_prefix, '_garments_', garment_prefix];
mkdir(tmp_result_folder);

L = mesh_smpl.vertices(garment_smpl.vertices_ind, :);
theta = smpl_param(11:82);

mesh_smpl_tmp = mesh_smpl;

for iter = 1 : 10
    mesh_smpl_tmp.vertices(garment_smpl.vertices_ind, :) = L;
    mesh_smpl_tmp.normals = calNormal(mesh_smpl_tmp.faces, mesh_smpl_tmp.vertices);
    
    param = [reshape(theta, 24, 3); L];
    
    options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
        'Display', 'iter-detailed', 'MaxIter', 10);
    param_opt = lsqnonlin(@(x) energy_garment(x, mesh_scan, mesh_smpl_tmp, ...
        garment_smpl, garment_scan, smpl_param), param, [], [], options);
    
    mesh_name_full = sprintf([garment_prefix, '_full_iter_%02d.obj'], iter);
    mesh_name_part = sprintf([garment_prefix, '_iter_%02d.obj'], iter);
    
    L = param_opt(25:end, :);
    theta = param_opt(1:24, :);
    
    mesh_full = mesh_smpl_tmp;
    mesh_full.vertices(garment_smpl.vertices_ind, :) = L;
    mesh_full.colors = render_labels(label_smpl);
    mesh_exporter([tmp_result_folder, filesep, mesh_name_full], mesh_full, true);
    
    mesh_part = mesh_full;
    mesh_part.faces = mesh_full.faces(garment_smpl.faces_ind, :);
    mesh_exporter([tmp_result_folder, filesep, mesh_name_part], mesh_part, true);
end

mesh_exporter([result_dir, filesep, mesh_prefix, '_shirt_full.obj'], mesh_shirt_full, true);
mesh_exporter([result_dir, filesep, mesh_prefix, '_shirt.obj'], mesh_shirt, true);

garment_vertices = L;
pose = theta;

end

