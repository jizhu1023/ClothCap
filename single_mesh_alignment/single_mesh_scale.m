function [mesh_scaled] = single_mesh_scale(mesh, scale)

global mesh_prefix;
global result_dir;

mesh_scaled = mesh;
mesh_scaled.vertices = mesh.vertices ./ scale;

mesh_exporter([result_dir, filesep, mesh_prefix, '_scale.obj'], mesh_scaled);

end
