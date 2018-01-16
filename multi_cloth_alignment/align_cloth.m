function [vertices, pose] = align_cloth(garment_scan, garment_smpl, ...
    mesh_scan, mesh_smpl, label_smpl)

global smpl_param;
global mesh_prefix;
global result_dir;

tmp_result_folder = [result_dir, filesep, mesh_prefix, '_clothing'];
mkdir(tmp_result_folder);

L = mesh_smpl.vertices;
theta = reshape(smpl_param(11:82), 24, 3);

mesh_tmp = mesh_smpl;

for iter = 1 : 10
    mesh_tmp.vertices = L;
    mesh_tmp.normals = calNormal(mesh_tmp.faces, mesh_tmp.vertices);
    
    param = [theta; L];
    
    options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
        'Display', 'iter-detailed', 'MaxIter', 10);
    param_opt = lsqnonlin(@(x) energy_cloth(x, mesh_scan, mesh_tmp, ...
        garment_smpl, garment_scan, smpl_param), param, [], [], options);
    
    L = param_opt(25:end, :);
    theta = param_opt(1:24, :);
    
    mesh_full = mesh_tmp;
    mesh_full.vertices = L;
    mesh_full.colors = render_labels(label_smpl);
    mesh_exporter([tmp_result_folder, filesep, ...
        sprintf('cloth_full_iter_%02d.obj', iter)], mesh_full, true);
end

mesh_exporter([result_dir, filesep, mesh_prefix, '_cloth_full.obj'], mesh_full, true);

vertices = L;
pose = reshape(theta, 1, 72);

end

