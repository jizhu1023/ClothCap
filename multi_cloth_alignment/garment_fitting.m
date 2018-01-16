function [] = garment_fitting( ...
    mesh_scan, label_scan, garments_scan, ...
    mesh_smpl, label_smpl, garments_smpl)

global is_first;
global mesh_prefix;
global result_dir;

% solve multi-cloth-template in 1st frame
if is_first == 1
    
    % for skin    
    [vertices_skin, pose_skin] = align_skin(garments_scan.skin, garments_smpl.skin, ...
        mesh_scan, mesh_smpl, label_smpl);
    save([result_dir, filesep, mesh_prefix, '_pose_skin.mat'], 'pose_skin');
    
    % for shirt    
    [vertices_shirt, pose_shirt] = align_garment(garments_scan.shirt, garments_smpl.shirt, ...
        mesh_scan, mesh_smpl, label_smpl, 'shirt');
    save([result_dir, filesep, mesh_prefix, '_pose_shirt.mat'], 'pose_shirt');

    % for pants    
    [vertices_pants, pose_pants] = align_garment(garments_scan.pants, garments_smpl.pants, ...
        mesh_scan, mesh_smpl, label_smpl, 'pants');
    save([result_dir, filesep, mesh_prefix, '_pose_pants.mat'], 'pose_pants');
    
    % combine all garments to one;
    mesh_combined = mesh_smpl;
    
    mesh_combined.vertices(garments_smpl.skin.vertices_ind, :) = vertices_skin;
    mesh_combined.vertices(garments_smpl.shirt.vertices_ind, :) = vertices_shirt;
    mesh_combined.vertices(garments_smpl.pants.vertices_ind, :) = vertices_pants;
    mesh_combined.normals = calNormal(mesh_combined.faces, mesh_combined.vertices);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_combined_full.obj'], mesh_combined, true);
    
    % for full mesh
    [vertices_all, pose] = align_cloth(garments_scan, garments_smpl, ...
        mesh_scan, mesh_combined, label_smpl);
    save([result_dir, filesep, mesh_prefix, '_pose_pants.mat'], 'pose');
    
else
     
    
   
end

end

