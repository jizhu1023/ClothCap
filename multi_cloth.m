clear all;
close all;
clc;

addpath('common');
addpath('smpl_model');
addpath('mesh_parser');
addpath('multi_cloth_alignment');

frame_start = 1;
frame_end = 525;

global is_first;
global smpl_model;
global smpl_param;
global mesh_prefix;
global result_dir;
global result_dir_base;	

smpl_model = load('smpl_m.mat');
smpl_model = smpl_model.model;

mesh_folder = 'body_easy';
mesh_format = '20171227-body-easy_texture_%08d_gop.obj';

result_dir_base = ['all_results', filesep, 'multi_cloth', ...
    filesep, mesh_folder];
mkdir(result_dir_base);

% initial SMPL data from 1st frame  
[label_smpl, garments_smpl] = initial_smpl(mesh_folder);

for frame = frame_start : frame_end
    % for first frame
    if frame == 1
        is_first = 1;
    else
        is_first = 0;
    end
    
    mesh_prefix = sprintf(mesh_format, frame);
    mesh_prefix = mesh_prefix(1:end-4);
    disp(['multi-cloth alignment: ', mesh_prefix]);
    
    result_dir = [result_dir_base, filesep, mesh_prefix];
    mkdir(result_dir);
    
    % load scan label
    label_path = ['all_results', filesep, 'segmentation', ...
        filesep, mesh_folder, filesep, mesh_prefix];
    label_name = [mesh_prefix, '_label_scan.mat'];
    label_scan = load([label_path, filesep, label_name]);
    label_scan = label_scan.seg_scan;
    
	% load scan mesh
    mesh_scan_name = [mesh_prefix, '.obj'];
    mesh_scan_path = ['scans', filesep, mesh_folder];
    mesh_scan = mesh_parser(mesh_scan_name, mesh_scan_path);
    mesh_scan.vertices = mesh_scan.vertices ./ 1000;
    mesh_scan.colors = render_labels(label_scan);
    
    % load scan garments
    garment_path = ['all_results', filesep, 'segmentation', ...
        filesep, mesh_folder, filesep, mesh_prefix];
    garment_name = [mesh_prefix, '_garments_scan.mat'];
    garments_scan = load([garment_path, filesep, garment_name]);
    garments_scan = garments_scan.garments_scan;
    
    % load smpl_param (for optimization initial)
    param_path = ['all_results', filesep, 'single_mesh', ...
        filesep, mesh_folder, filesep, mesh_prefix];
    param_name = [mesh_prefix, '_fit_param.mat'];
    smpl_param = load([param_path, filesep, param_name]);
    smpl_param = smpl_param.param;
    
    % load smpl mesh (for optimization initial)
    mesh_smpl_path = ['all_results', filesep, 'single_mesh', ...
        filesep, mesh_folder, filesep, mesh_prefix];
    mesh_smpl_name = [mesh_prefix, '_fit.obj'];
    mesh_smpl = mesh_parser(mesh_smpl_name, mesh_smpl_path);
    mesh_smpl.colors = render_labels(label_smpl);
    
    % garments fitting
    garment_fitting( ...
        mesh_scan, label_scan, garments_scan, ...
        mesh_smpl, label_smpl, garments_smpl);
    
end