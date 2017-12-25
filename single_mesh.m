clear all;
close all;
clc;

addpath('smpl_model');
addpath('mesh_parser');
addpath('single_mesh_alignment')

mesh_folder = ['scans', filesep, 'celina-s2-t9-b4_texture'];
mesh_name = 'celina-s2-t9-b4_texture_%08d_gop.obj';

frame_start = 1812;
frame_end = 1832;

% global varibles used in single mesh alignment
global is_first;
global smpl_model;
global mesh_prefix;
global mesh_prefix_last;
global result_dir;

smpl_model = load('smpl_f.mat');
smpl_model = smpl_model.model;

for frame = frame_start : frame_start
    % for first frame
    if frame == frame_start
        is_first = 1;
        mesh_prefix_last = '';
    else
        is_first = 0;
        mesh_prefix_last = sprintf(mesh_name, frame - 1);
    end
    
    mesh_name = sprintf(mesh_name, frame);
    mesh_prefix = mesh_name(1:end-4);
    disp(['Processing mesh ', mesh_prefix, ' ...']);
    
    mesh = mesh_parser(mesh_name, mesh_folder);
    
    result_dir = ['all_results/single_mesh', filesep, mesh_prefix];
    mkdir(result_dir);
    
    % single mesh alignment
    
    % s1_scale_scan
    mesh_scaled_scan = single_mesh_scale(mesh, 1000);

    % s2_align_scan
    param_init = single_mesh_trans(mesh_scaled_scan);

    % s3_fit_scan
    [param_fitted_smpl, mesh_fitted_smpl] = single_mesh_fitting(mesh_scaled_scan, param_init);

    % s4_opt_single_mesh_3s_GMdist
    [m_smpl, m_A, param] = single_mesh_align(mesh_scaled_scan, mesh_fitted_smpl, param_fitted_smpl);
 
end


