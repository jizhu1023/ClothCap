clear all;
close all;
clc;

addpath('smpl_model');
addpath('mesh_parser');
addpath('segmentation');
addpath('segmentation/prior');

mesh_folder = ['scans', filesep, 'ly-apose_texture'];
mesh_format = 'ly-apose_texture_%08d_gop.obj';

frame_start = 1;
frame_end = 10;

% global varibles used in single mesh alignment
global is_first;
global smpl_model;
global mesh_prefix;
global result_dir;

smpl_model = load('smpl_m.mat');
smpl_model = smpl_model.model;

prior = get_prior();

for frame = frame_start : frame_start
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
    
    % get unary
    unary = get_unary(mesh_scan, mesh_smpl, prior, 3);
    
    
    
    
    
end