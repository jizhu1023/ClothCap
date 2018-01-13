function [] = garment_fitting( ...
    mesh_scan, label_scan, garments_scan, ...
    mesh_smpl, label_smpl, garments_smpl)

global is_first;
global mesh_prefix;
global result_dir;

% solve multi-cloth-template in 1st frame
if is_first == 1
    % for skin    
%     align_garment(garments_scan.skin, garments_smpl.skin, ...
%         mesh_scan, mesh_smpl, label_smpl, smpl_param, 'skin');
    
    % for shirt    
    [garment_vertices_shirt, pose_shirt] = align_garment(garments_scan.shirt, garments_smpl.shirt, ...
        mesh_scan, mesh_smpl, label_smpl, 'shirt');
    save([result_dir, filesep, mesh_prefix, '_pose_shirt.mat'], 'pose_shirt');

    % for pants    
    [garment_vertices_pants, pose_pants] = align_garment(garments_scan.pants, garments_smpl.pants, ...
        mesh_scan, mesh_smpl, label_smpl, 'pants');
    save([result_dir, filesep, mesh_prefix, '_pose_pants.mat'], 'pose_pants');
else
     
    
   
end

end

