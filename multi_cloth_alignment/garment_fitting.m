function [] = garment_fitting(mesh_scan, label_scan, garments_scan)

global is_first;
global smpl_model;
global mesh_prefix;
global result_dir;
global n_smpl;

% solve multi-cloth-template in 1st frame
if is_first == 1
    label_folder = ['all_results', filesep, 'segmentation', filesep, mesh_prefix];
    label_smpl = load([label_folder, filesep, mesh_prefix, '_label_smpl.mat']);
    label_smpl = label_smpl.seg_smpl;  
    n_smpl = length(label_smpl);
    
    % initial beta and pose
    param_folder = ['all_results', filesep, 'single_mesh', filesep, mesh_prefix];
    smpl_param = load([param_folder, filesep, mesh_prefix, '_aligned_param.mat']);
    smpl_param = smpl_param.param;
    
    [betas, pose, trans, scale] = divideParam(smpl_param);
    [v_shaped, j_shaped] = calShapedMesh(smpl_model, betas);
    [v_posed] = calPosedMesh(smpl_model, pose, v_shaped, j_shaped, 0);
    v_posed = repmat(trans, n_smpl, 1) + v_posed * scale;
    
    mesh_smpl = mesh_parser('smpl_base_m.obj', 'smpl_model');
    mesh_smpl.vertices = v_posed;
    mesh_smpl.normals = calNormal(mesh_smpl.faces, mesh_smpl.vertices);
    
    % get the smpl model garments
    [garments_smpl, mesh_garments_smpl] = extract_garments(mesh_smpl, label_smpl);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_garments_smpl.obj'], mesh_garments_smpl, true);
    save([result_dir, filesep, mesh_prefix, '_garments_smpl.mat'], 'garments_smpl');
    
    % for skin    
%     align_garment(garments_scan.skin, garments_smpl.skin, ...
%         mesh_scan, mesh_smpl, label_smpl, smpl_param, 'skin');
    
    % for shirt    
    [mesh_shirt_full, mesh_shirt, pose_shirt] = align_garment(garments_scan.shirt, garments_smpl.shirt, ...
        mesh_scan, mesh_smpl, label_smpl, smpl_param, 'shirt');
    mesh_exporter([result_dir, filesep, mesh_prefix, '_shirt_full.obj'], mesh_shirt_full, true);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_shirt.obj'], mesh_shirt, true);
    
    % for pants    
    [mesh_pants_full, mesh_pants, pose_pants] = align_garment(garments_scan.pants, garments_smpl.pants, ...
        mesh_scan, mesh_smpl, label_smpl, smpl_param, 'pants');
    mesh_exporter([result_dir, filesep, mesh_prefix, '_pants_full.obj'], mesh_pants_full, true);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_pants.obj'], mesh_pants, true);
else
     
    
    
end



end

