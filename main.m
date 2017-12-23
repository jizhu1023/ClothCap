clear all;
close all;
clc;

addpath('mesh_parser');
addpath('smpl_model');
addpath('single_mesh_alignment');

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

smpl_model = load('smpl_model/smpl_f.mat');
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
    
    result_dir = ['results', filesep, mesh_prefix];
    mkdir(result_dir);
    
    % single mesh alignment
    single_mesh(mesh);
    
    % segmentation
    
    
    
    
    
end


