clear all;
close all;
clc;

addpath('smpl_model');
addpath('mesh_parser');
addpath('segmentation');
addpath('segmentation/prior');

mesh_folder = ['scans', filesep, 'ly-apose_texture'];
mesh_scan_name = 'ly-apose_texture_%08d_gop.obj';

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
    
    mesh_scan_name = sprintf(mesh_scan_name, frame);
    mesh_prefix = mesh_scan_name(1:end-4);
    disp(['Segmentation ', mesh_prefix, ' ...']);
    
    mesh_smpl_name = [sprintf(mesh_prefix, frame), '_aligned_SMPL.obj'];
    mesh_smpl_folder = ['all_results/single_mesh', filesep, mesh_prefix];
    
    result_dir = ['all_results/segmentation', filesep, mesh_prefix];
    mkdir(result_dir);
    
    % load scan mesh
    mesh_scan = mesh_parser(mesh_scan_name, mesh_folder);
    mesh_scan.colors = render_texture(mesh_scan.tex_coords, mesh_scan.uv_map);
    
    % load single mesh alignment
    mesh_smpl = mesh_parser(mesh_smpl_name, mesh_smpl_folder);
    
    a = 0;
    
    
end