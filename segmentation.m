clear all;
close all;
clc;

addpath('common');
addpath('smpl_model');
addpath('mesh_parser');
addpath('sdf_extractor');
addpath('segmentation');

addpath('3rdparty/gco-v3.0');
addpath('3rdparty/gco-v3.0/matlab');

frame_start = 1;
frame_end = 525;

% global varibles used in single mesh alignment
global is_first;
global mesh_prefix;
global mesh_prefix_last;
global result_dir;
global result_dir_base;	

mesh_folder = 'body_easy';
mesh_format = '20171227-body-easy_texture_%08d_gop.obj';

result_dir_base = ['all_results', filesep, 'segmentation', filesep, mesh_folder];
mkdir(result_dir_base);

% get smpl prior
prior_smpl = get_smpl_prior();

for frame = frame_start : frame_end
    % for first frame
    if frame == 1
        is_first = 1;
        mesh_prefix_last = '';
    else
        is_first = 0;
        mesh_prefix_last = sprintf(mesh_format, frame - 1);
        mesh_prefix_last = mesh_prefix_last(1:end-4);
    end
    
    mesh_prefix = sprintf(mesh_format, frame);
    mesh_prefix = mesh_prefix(1:end-4);
    disp(['segmentation: ', mesh_prefix]);
    
    result_dir = [result_dir_base, filesep, mesh_prefix];
    mkdir(result_dir);
    
    mesh_scan_name = [mesh_prefix, '.obj'];
    mesh_scan_folder = ['scans', filesep, mesh_folder];
    
    mesh_smpl_name = [mesh_prefix, '_fit.obj'];
    mesh_smpl_folder = ['all_results', filesep, 'single_mesh', ...
        filesep, mesh_folder, filesep, mesh_prefix];
    
    % load scan mesh
    mesh_scan = mesh_parser(mesh_scan_name, mesh_scan_folder);
    mesh_scan.vertices = mesh_scan.vertices ./ 1000;
    mesh_scan.colors = render_texture(mesh_scan.tex_coords, mesh_scan.uv_map);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_colored.obj'], mesh_scan, true);
    
    % load single mesh alignment
    mesh_smpl = mesh_parser(mesh_smpl_name, mesh_smpl_folder);
    
    % calculate scan prior
    prior_scan = get_scan_prior(mesh_smpl, mesh_scan, prior_smpl);
    
    % get unary term
    % for both scan and smpl
    [unary_scan, unary_smpl] = calculate_unary( ...
        mesh_scan, mesh_smpl, prior_scan, prior_smpl);
    
    % gco segmentation
    % for both scan and smpl
    [seg_scan, seg_smpl] = gco_segment( ...
        mesh_scan, mesh_smpl, unary_scan, unary_smpl);
        
    % map smpl segmentation back
    [seg_scan_map] = label_nearest( ...
        mesh_scan, mesh_smpl, seg_scan, seg_smpl);
    
    % manually modify the result, only for 1st frame
    if is_first == 1
        [seg_scan, seg_smpl] = manually_modify(...
            mesh_scan, mesh_smpl, seg_scan, seg_smpl);
    end

    % fit a GMM model
    gmm_fitting(mesh_scan, seg_scan);
    
    % render and save result
    mesh_scan_final = mesh_scan;
    mesh_scan_final.colors = render_labels(seg_scan);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_seg_scan.obj'], ...
        mesh_scan_final, true);
    
    mesh_smpl_final = mesh_smpl;
    mesh_smpl_final.colors = render_labels(seg_smpl);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_seg_smpl.obj'], ...
        mesh_smpl_final, true);
    
    save([result_dir, filesep, mesh_prefix, '_label_scan.mat'], 'seg_scan');
    save([result_dir, filesep, mesh_prefix, '_label_smpl.mat'], 'seg_smpl');
    
    % extract and save scan garments
    [garments_scan, mesh_garments_scan] = extract_garments(mesh_scan, seg_scan);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_garments_scan.obj'], mesh_garments_scan, true);
    save([result_dir, filesep, mesh_prefix, '_garments_scan.mat'], 'garments_scan');
    
    if is_first == 1
        save([result_dir_base, filesep, 'person_wise_label_scan.mat'], 'seg_scan');
        save([result_dir_base, filesep, 'person_wise_label_smpl.mat'], 'seg_smpl');
    end
end