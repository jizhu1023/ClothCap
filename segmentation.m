clear all;
close all;
clc;

addpath('smpl_model');
addpath('mesh_parser');
addpath('segmentation');

frame_start = 1;
frame_end = 1;

% global varibles used in single mesh alignment
global is_first;
global mesh_prefix;
global result_dir;

mesh_format = 'ly-apose_texture_%08d_gop.obj';

% get smpl prior
prior_smpl = get_smpl_prior();

for frame = frame_start : frame_end
    % for first frame
    if frame == frame_start
        is_first = 1;
    else
        is_first = 0;
    end
    
    mesh_prefix = sprintf(mesh_format, frame);
    mesh_prefix = mesh_prefix(1:end-4);
    disp(['Segmentation ', mesh_prefix, ' ...']);
    
    result_dir = ['all_results', filesep, 'segmentation', filesep, mesh_prefix];
    mkdir(result_dir);
    
    mesh_scan_name = [mesh_prefix, '.obj'];
    mesh_scan_folder = ['scans', filesep, 'ly-apose_texture'];
    
    mesh_smpl_name = [sprintf(mesh_prefix, frame), '_aligned_SMPL.obj'];
    mesh_smpl_folder = ['all_results', filesep, 'single_mesh', filesep, mesh_prefix];
    
    % load scan mesh
    mesh_scan = mesh_parser(mesh_scan_name, mesh_scan_folder);
    mesh_scan.vertices = mesh_scan.vertices ./ 1000;
    mesh_scan.colors = render_texture(mesh_scan.tex_coords, mesh_scan.uv_map);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_colored.obj'], mesh_scan, true);
    
    % load single mesh alignment
    mesh_smpl = mesh_parser(mesh_smpl_name, mesh_smpl_folder);
    
    % calculate scan prior
    prior_scan = get_scan_prior(mesh_smpl, mesh_scan, prior_smpl);
    
    % get unary
    [unary_scan, unary_smpl] = calculate_unary(mesh_scan, mesh_smpl, prior_scan, prior_smpl);
    
    % meanfield densecrf
    [seg_scan, seg_smpl] = meanfield(mesh_scan, mesh_smpl, unary_scan, unary_smpl);
    
    % manually modify the result
    [seg_scan, seg_smpl] = manually_modify(mesh_scan, mesh_smpl, seg_scan, seg_smpl);
    
    % render and save result
    mesh_scan_final = mesh_scan;
    mesh_scan_final.colors = render_result(seg_scan);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_seg_scan.obj'], mesh_scan_final, true);
    mesh_smpl_final = mesh_smpl;
    mesh_smpl_final.colors = render_result(seg_smpl);
    mesh_exporter([result_dir, filesep, mesh_prefix, '_seg_smpl.obj'], mesh_smpl_final, true);
    
    save([result_dir, filesep, mesh_prefix, '_label_scan.mat'], 'seg_scan');
    save([result_dir, filesep, mesh_prefix, '_label_smpl.mat'], 'seg_smpl');
end