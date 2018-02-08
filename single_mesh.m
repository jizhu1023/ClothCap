clear all;
close all;
clc;

addpath('common');
addpath('smpl_model');
addpath('mesh_parser');
addpath('single_mesh_alignment')

mesh_folder = 'body_easy';
mesh_format = '20171227-body-easy_texture_%08d_gop.obj';

frame_start = 1;
frame_end = 525;

global is_first;
global smpl_model;
global mesh_prefix;
global mesh_prefix_last;
global result_dir;
global result_dir_base;	

result_dir_base = ['all_results', filesep, 'single_mesh', filesep, mesh_folder];
mkdir(result_dir_base);

smpl_model = load('smpl_m.mat');
smpl_model = smpl_model.model;

for frame = frame_start : frame_end
    % for first frame
    if frame == frame_start
        is_first = 1;
        mesh_prefix_last = '';
    else
        is_first = 0;
        mesh_prefix_last = sprintf(mesh_format, frame - 1);
        mesh_prefix_last = mesh_prefix_last(1:end-4);
    end
    
    mesh_prefix = sprintf(mesh_format, frame);
    mesh_prefix = mesh_prefix(1:end-4);
    disp(['single_mesh: ', mesh_prefix]);
    
    result_dir = [result_dir_base, filesep, mesh_prefix];
    mkdir(result_dir);
    
    mesh_scan_name = [mesh_prefix, '.obj'];
    mesh_scan_folder = ['scans', filesep, mesh_folder];
    
    mesh = mesh_parser(mesh_scan_name, mesh_scan_folder);
    
    % single mesh alignment
    
    % s1_scale_scan
    mesh_scaled_scan = single_mesh_scale(mesh, 1000);

    % s2_align_scan
    param_init = single_mesh_trans(mesh_scaled_scan);

    % s3_fit_scan
    [param_fitted_smpl, mesh_fitted_smpl] = single_mesh_fitting(mesh_scaled_scan, param_init);

%     % s4_opt_single_mesh_3s_GMdist
%     [m_smpl, m_A, param] = single_mesh_align(mesh_scaled_scan, mesh_fitted_smpl, param_fitted_smpl);
 
end


