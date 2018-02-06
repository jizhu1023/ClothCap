function [seg_scan_map] = label_nearest(mesh_scan, mesh_smpl, seg_scan, seg_smpl)

global mesh_prefix;
global result_dir;

nearest_ind = knnsearch(mesh_smpl.vertices, mesh_scan.vertices);
seg_scan_map = seg_smpl(nearest_ind);

m = mesh_scan;
m.colors = render_labels(seg_scan_map);
mesh_exporter([result_dir, filesep, mesh_prefix, '_seg_scan_map.obj'], m, true);

end

