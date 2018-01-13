function [m_smpl, m_A, param] = single_mesh_align(mesh_scan, mesh_smpl, param_init)

global is_first;
global smpl_model;
global mesh_prefix;
global mesh_prefix_last;
global result_dir;

% vertices in SMPL model
n_smpl = size(smpl_model.v_template, 1);

max_iter = 20;
if is_first == 0
    max_iter = 10;
end

mesh_tmp_dir = [result_dir, filesep, mesh_prefix, '_align_tmp'];
mkdir(mesh_tmp_dir);

A_init_vertices = mesh_smpl.vertices;
A_init_faces = mesh_smpl.faces;

scan_vertices = mesh_scan.vertices;
scan_faces = mesh_scan.faces;

param = param_init;
beta = param(1:10);
pose = param(11:82);
trans = param(83:85);
scale = 1;

[A_init_normals] = calNormal(A_init_faces, A_init_vertices);
[scan_normals] = calNormal(scan_faces, scan_vertices);

param_init = param;
param = param_init;

A_vertices = A_init_vertices;

for loop = 1 : max_iter
    A_normals = calNormal(A_init_faces, A_vertices);
    m_name = sprintf([mesh_tmp_dir, filesep, 'A1_iter_%04d.obj'], loop-1);
    if exist(m_name, 'file')
        m_name = sprintf([mesh_tmp_dir, filesep, 'A1_iter_%04d_%3f.obj'], loop-1, now);
    end
    m.vertices = A_vertices;
    m.faces = A_init_faces;
    mesh_exporter(m_name, m);  
    
    
    %% 1
    nearest_ind_s2a = knnsearch(A_vertices, scan_vertices);
    error_n = dot(scan_normals.', A_normals(nearest_ind_s2a, :).').';
    mask_s2a = find(error_n > 0);
    fprintf('normal match number %d\n', length(mask_s2a));
    nearest_pts_s2a = scan_vertices(mask_s2a, :);
    nearest_ind_s2a = nearest_ind_s2a(mask_s2a);
    
    nearest_ind_a2s = knnsearch(scan_vertices, A_vertices);
    error_n = dot(scan_normals(nearest_ind_a2s,:).', A_normals.').';
    mask_a2s = find(error_n > 0);
    rand_ind = randperm(length(mask_a2s));
    mask_a2s = mask_a2s(rand_ind(1:min(2000, length(mask_a2s))));
    nearest_pts_a2s = scan_vertices(nearest_ind_a2s, :);
    nearest_pts_a2s = nearest_pts_a2s(mask_a2s,:);
    
    % solve param1
    param1 = [beta, pose, trans, scale];
    options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
        'Display', 'iter-detailed', 'MaxIter', 10);
    options = optimoptions(options, 'UseParallel', true);
    param_opt1 = lsqnonlin(@(x) SingleMeshEnergy1(x, smpl_model, A_vertices, nearest_pts_s2a, ...
        nearest_ind_s2a, n_smpl), param1, [], [], options);
    
    
    %% 2   
    [beta, pose, trans, scale] = divideParam(param_opt1(1:86));
    [v_shaped, j_shaped] = calShapedMesh(smpl_model, beta);
    [v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
    v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;
    
    m_name = sprintf([mesh_tmp_dir, filesep, 'Model_iter_%04d.obj'], loop-1);
    if exist(m_name, 'file')
        m_name = sprintf([mesh_tmp_dir, filesep, 'Model_iter_%04d_%3f.obj'], loop-1, now);
    end
    m.vertices = v_posed;
    m.faces = smpl_model.f + 1;
    mesh_exporter(m_name, m);  
    
    % solve param2
    A_vertices = reshape(A_vertices', [numel(A_vertices), 1]);
    param2 = A_vertices;
    % options = optimoptions(@lsqnonlin, 'Algorithm', 'levenberg-marquardt', ...
    %   'Display', 'iter-detailed', 'MaxIter', 10, 'MaxFunEvals', 40000);
    options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton', ...
        'Display', 'iter-detailed', 'MaxIter', 10, 'MaxFunEvals', 1000000);
    options = optimoptions(options, 'UseParallel', true);
    param_opt2 = fminunc(@(x) SingleMeshEnergy2(x, smpl_model, v_posed, nearest_pts_s2a, ...
        nearest_ind_s2a), param2, options);
    
    
    %% 3
    A_vertices = param_opt2;
    A_vertices = reshape(A_vertices, [3, floor(numel(A_vertices)/ 3)])';
    
    m_name = sprintf([mesh_tmp_dir, filesep, 'A2_iter_%04d.obj'], loop-1);
    if exist(m_name, 'file')
        m_name = sprintf([mesh_tmp_dir, filesep, 'A2_iter_%04d_%3f.obj'], loop-1, now);
    end
	m.vertices = A_vertices;
    m.faces = A_init_faces;
    mesh_exporter(m_name, m);  

    mask_s2a2 = unique(nearest_ind_s2a);
    mask = union(mask_a2s, mask_s2a2);
    mask = setdiff((1:size(A_vertices, 1)), mask);
    mask1 = (mask - 1) * 3 + 1;
    mask2 = (mask - 1) * 3 + 2;
    mask3 = (mask - 1) * 3 + 3;
    mask = [mask1, mask2, mask3];
    
    A_vertices = reshape(A_vertices', [numel(A_vertices), 1]);
    param = A_vertices;
    I_matrix = eye(numel(param));
    A_eq = I_matrix(mask,:);
    b_eq = param(mask,:);
    
    % para_opt = lsqnonlin(@(x) SingleMeshEnergy2(x,model,A_pts, nearstPts_s2a,nearstIdx_s2a),para, [], [], options);
    
    options = optimoptions('fmincon', 'GradObj', 'off', 'Display', 'iter-detailed', ...
        'MaxIter', 10, 'MaxFunEvals', 300000);
    options = optimoptions(options, 'UseParallel', true);
    param_opt = fmincon(@(x) SingleMeshEnergy_GMdist(x, smpl_model, A_vertices, nearest_pts_s2a, ...
        nearest_ind_s2a, nearest_pts_a2s, mask_a2s), param, [], [], A_eq, b_eq, [], [], [], options);

    A_vertices = reshape(param_opt, [3, floor(numel(param_opt)/ 3)])';
    
    m_name = sprintf([mesh_tmp_dir, filesep, 'A3_iter_%d.obj'], loop-1);
    if exist(m_name, 'file')
        m_name = sprintf([mesh_tmp_dir, filesep, 'A3_iter_%d_%3f.obj'], loop-1, now);
    end
    m.vertices = A_vertices;
    m.faces = A_init_faces;
    mesh_exporter(m_name, m); 
    
end

[v_shaped, j_shaped] = calShapedMesh(smpl_model, beta);
[v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;

% fitted and aligned SMPL
m_smpl.vertices = v_posed;
m_smpl.faces = smpl_model.f + 1;
mesh_smpl_file = [result_dir, filesep, mesh_prefix, '_aligned_SMPL.obj'];
mesh_exporter(mesh_smpl_file, m_smpl);

% fitted and aligned A
m_A.vertices = A_vertices;
m_A.faces = smpl_model.f + 1;
mesh_A_file = [result_dir, filesep, mesh_prefix, '_aligned_A.obj'];
mesh_exporter(mesh_A_file, m_A);

% SMPL parameters
param_smpl_file = [result_dir, filesep, mesh_prefix, '_aligned_param.mat'];
param = [beta, pose, trans, scale];
save(param_smpl_file, 'param')

mesh_prefix_last = param_smpl_file;

end

