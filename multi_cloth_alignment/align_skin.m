function [vertices, pose] = align_skin(skin_garment_scan, ...
    skin_garment_smpl, mesh_scan, mesh_smpl, label_smpl)

global smpl_param;
global mesh_prefix;
global result_dir;

tmp_result_folder = [result_dir, filesep, mesh_prefix, '_garments_skin'];
mkdir(tmp_result_folder);

L = mesh_smpl.vertices(skin_garment_smpl.vertices_ind, :);
theta = reshape(smpl_param(11:82), 24, 3);

mesh_smpl_tmp = mesh_smpl;

for iter = 1 : 10
    mesh_smpl_tmp.vertices(skin_garment_smpl.vertices_ind, :) = L;
    mesh_smpl_tmp.normals = calNormal(mesh_smpl_tmp.faces, mesh_smpl_tmp.vertices);
    
    param = [theta; L];
    
    options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
        'Display', 'iter-detailed', 'MaxIter', 10);
    param_opt = lsqnonlin(@(x) energy_skin(x, mesh_scan, mesh_smpl_tmp, ...
        skin_garment_smpl, skin_garment_scan, smpl_param), param, [], [], options);
    
    mesh_name_full = sprintf('skin_full_iter_%02d.obj', iter);
    mesh_name_part = sprintf('skin_iter_%02d.obj', iter);
    
    L = param_opt(25:end, :);
    theta = param_opt(1:24, :);
    
    mesh_full = mesh_smpl_tmp;
    mesh_full.vertices(skin_garment_smpl.vertices_ind, :) = L;
    mesh_full.colors = render_labels(label_smpl);
    mesh_exporter([tmp_result_folder, filesep, mesh_name_full], mesh_full, true);
    
    mesh_part = mesh_full;
    mesh_part.faces = mesh_full.faces(skin_garment_smpl.faces_ind, :);
    mesh_exporter([tmp_result_folder, filesep, mesh_name_part], mesh_part, true);
end

mesh_exporter([result_dir, filesep, mesh_prefix, '_skin_full.obj'], mesh_full, true);
mesh_exporter([result_dir, filesep, mesh_prefix, '_skin.obj'], mesh_part, true);

vertices = L;
pose = reshape(theta, 1, 72);

end
