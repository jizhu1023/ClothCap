function [label_smpl, garments_smpl, mesh_smpl] = initial_smpl(mesh_folder)

global n_smpl;
global result_dir_base;	

% load SMPL label from 1st frame
label_smpl = load(['all_results', filesep, 'segmentation', filesep, ...
    mesh_folder, filesep, 'person_wise_label_smpl.mat']);
label_smpl = label_smpl.seg_smpl;  

n_smpl = length(label_smpl);

mesh_smpl = mesh_parser('smpl_base_m.obj', 'smpl_model');
mesh_smpl.colors = render_labels(label_smpl);

% get the smpl model garments
[garments_smpl, mesh_garments_smpl] = extract_garments(mesh_smpl, label_smpl);

mesh_exporter([result_dir_base, filesep, 'smpl_garments.obj'], ...
    mesh_garments_smpl, true);
save([result_dir_base, filesep, 'smpl_garments.mat'], 'garments_smpl');

end
