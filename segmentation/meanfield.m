function [seg_scan, seg_smpl] = meanfield(mesh_scan, mesh_smpl, unary_scan, unary_smpl)

% cd(['3rdparty', filesep, 'meanfield-matlab-master']);
% 
% n_scan = size(mesh_scan.vertices, 1);
% n_smpl = size(mesh_smpl.vertices, 1);
% 
% im = uint8(zeros(2048, 2048, 3));
% un = single(zeros(2048, 2048, 3));
% 
% D = Densecrf(im, un);
% 
% D.vertices = mesh_scan.vertices;
% D.vertices_unary = unary_scan;
% D.colors = mesh_scan.colors;
% 
% D.gaussian_x_stddev = 3;
% D.gaussian_y_stddev = 3;
% D.gaussian_weight = 1;
% 
% D.bilateral_x_stddev = 30;
% D.bilateral_y_stddev = 30;
% D.bilateral_r_stddev = 10;
% D.bilateral_g_stddev = 10;
% D.bilateral_b_stddev = 10;
% D.bilateral_weight = 1;

% D.mean_field2;
% seg_scan = D.seg;

[~, seg_scan] = min(unary_scan, [], 2);
[~, seg_smpl] = min(unary_smpl, [], 2);

seg_scan = seg_scan - 1;
seg_smpl = seg_smpl - 1;

% cd(['..', filesep, '..']);

end

