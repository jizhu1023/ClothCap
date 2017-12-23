function [param] = estimate_fitting(smpl_model, vertices, normals, max_iter, if_shape, ...
    param_init, mesh_prefix, result_dir)

param = param_init;
params_per_iter = [];

n_smpl = size(smpl_model.v_template, 1);

mesh_tmp_dir = [result_dir, filesep, mesh_prefix, '_fit_tmp'];
mkdir(mesh_tmp_dir);

for loop = 1 : max_iter
    [betas, pose, trans, scale] = divideParam(param);
    [v_shaped, j_shaped] = calShapedMesh(smpl_model, betas);
    [v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
    v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;
    normal_posed = calNormal(smpl_model.f + 1, v_posed);
        
    params_per_iter = [params_per_iter; param];
    
    nearest_ind_d2m = knnsearch(v_posed, vertices);
    error_n = dot(normals.', normal_posed(nearest_ind_d2m, :).').';
    mask_d2m = find(error_n > 0);
    % rand_select = randperm(length(mask_d2m));
    % mask_d2m = mask_d2m(rand_select(1:round(length(rand_select)/3)));
    fprintf('normal match number %d\n', length(mask_d2m));
    nearest_pts_d2m = vertices(mask_d2m, :);
    nearest_ind_d2m = nearest_ind_d2m(mask_d2m);
    
    nearest_ind_m2d = knnsearch(vertices, v_posed);
    nearest_pts_m2d = vertices(nearest_ind_m2d, :);
    error_n = dot(normals(nearest_ind_m2d, :).', normal_posed.').';
    mask_m2d = find(error_n > 0);
    % rand_select = randperm(length(mask_m2d));
    % mask_m2d = mask_m2d(rand_select(1:round(length(rand_select)/3)));
    nearest_ind_m2d = nearest_ind_m2d(mask_m2d);
    nearest_pts_m2d = nearest_pts_m2d(mask_m2d, :);
    
    options = optimoptions('fmincon', 'GradObj', 'off', 'Display', 'iter-detailed', 'MaxIter', 10);
    options = optimoptions(options, 'UseParallel', true);
    mask = [1:10, 86];
    % mask = [1:85];
    I_matrix = eye(86);
    A_eq = I_matrix(mask, :);
    b_eq = param(mask)';
    
    para_opt = fmincon(@(x) ICPEnergy(x, smpl_model, nearest_pts_d2m, nearest_ind_d2m, ...
        nearest_pts_m2d, mask_m2d, n_smpl), param, [], [], A_eq, b_eq, [], [], [], options);
    
    param = para_opt;
        
    if if_shape
        [betas, pose, trans, scale] = divideParam(param);
        [v_shaped, j_shaped] = calShapedMesh(smpl_model, betas);
        [v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
        v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;
        normal_posed = calNormal(smpl_model.f+1, v_posed);

        mesh_file = [mesh_tmp_dir, filesep, sprintf('v_iter_pose_%04d.obj', loop - 1)];
        mesh.vertices = v_posed;
        mesh.faces = smpl_model.f + 1;
        mesh_exporter(mesh_file, mesh);
        
        params_per_iter = [params_per_iter; param];

        nearest_ind_d2m = knnsearch(v_posed, vertices);
        error_n = dot(normals.', normal_posed(nearest_ind_d2m, :).').';
        mask_d2m = find(error_n > 0.5);
        fprintf('normal match number %d\n', length(mask_d2m));
        nearest_pts_d2m = vertices(mask_d2m, :);
        nearest_ind_d2m = nearest_ind_d2m(mask_d2m);

        nearest_ind_m2d = knnsearch(vertices,v_posed);
        nearest_pts_m2d = vertices(nearest_ind_m2d, :);
        error_n = dot(normals(nearest_ind_m2d, :).', normal_posed.').';
        mask_m2d = find(error_n > 0.5);
        nearest_ind_m2d = nearest_ind_m2d(mask_m2d);
        nearest_pts_m2d = nearest_pts_m2d(mask_m2d, :);

        options = optimoptions('fmincon', 'GradObj', 'off', 'Display', 'iter-detailed', 'MaxIter', 10);
        options = optimoptions(options, 'UseParallel', true);
        mask = [11:82, 86];
        % mask = [1:85];
        I_matrix = eye(86);
        A_eq = I_matrix(mask, :);
        b_eq = param(mask)';

        para_opt = fmincon(@(x) ICPEnergy(x, smpl_model, nearest_pts_d2m, nearest_ind_d2m, ...
            nearest_pts_m2d, mask_m2d, n_smpl), param, [], [], A_eq, b_eq, [], [], [], options);

        param = para_opt;
    end 
    
    param_file = [mesh_tmp_dir, filesep, sprintf('param_iter_%04d.mat', loop - 1)];
    save(param_file, 'param');
   
end

end

function [energy] = ICPEnergy(x, model, nearest_pts_d2m, nearest_ind_d2m, ...
    nearest_pts_m2d, mask_m2d, n_smpl)

[betas, pose, trans, scale] = divideParam(x);
[v_shaped, j_shaped] = calShapedMesh(model, betas);
[v_posed] = calPosedMesh(model, pose, v_shaped, j_shaped, 0);
v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;

error = nearest_pts_d2m - v_posed(nearest_ind_d2m, :);
energy = 0;

sigma = 0.1;
energy = energy + sum(sum(error.^2 ./ (error.^2 + sigma^2)));

error = nearest_pts_m2d - v_posed(mask_m2d, :);
energy = energy + sum(sum(error.^2 ./ (error.^2 + sigma^2)));

end
